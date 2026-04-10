using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using System.Reflection;
using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using TrippieBackend.Common;
using TrippieBackend.Hubs;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Services;
using TrippieBackend.Seeds;

namespace TrippieBackend;

public class Program {
    public static async Task Main(string[] args) {
        var builder = WebApplication.CreateBuilder(args);
        
        builder.Services.AddControllers()
            .AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
            });
        
        builder.Services.AddSignalR();

        builder.Services.AddDbContext<TrippieContext>(options =>
            options.UseNpgsql(builder.Configuration.GetConnectionString("TrippieConnectionString"), o => 
                o.MapEnum<ThemeEnum>("theme_enum")
                .MapEnum<TransportTypeEnum>("transport_type_enum")
                .MapEnum<TripStatusEnum>("trip_status_enum")
                .MapEnum<TripRoleEnum>("trip_role_enum")
                .MapEnum<TravelDirectionEnum>("travel_direction_enum")
            )
            .UseAsyncSeeding(async (context, _, cancellationToken) =>
            {
                await AirportSeeder.SeedAsync(context, cancellationToken);         // no deps
                await PlaceSeeder.SeedAsync(context, cancellationToken);           // no deps
                await UserSeeder.SeedAsync(context, cancellationToken);            // no deps
                await TripSeeder.SeedAsync(context, cancellationToken);            // → Users, Places
                await TripMemberSeeder.SeedAsync(context, cancellationToken);      // → Trips, Users
                await FlightSeeder.SeedAsync(context, cancellationToken);          // → Trips, Airports
                await AccommodationSeeder.SeedAsync(context, cancellationToken);   // → Trips, Places
                await ActivitySeeder.SeedAsync(context, cancellationToken);        // → Trips, Places, Users
                await FavoriteSeeder.SeedAsync(context, cancellationToken);        // → Users, Places
            })
            // .UseLoggerFactory(LoggerFactory.Create(b =>
            //     b.AddConsole()
            //         .AddFilter("Microsoft.EntityFrameworkCore.Database.Command", LogLevel.Warning)
            // ))
            , ServiceLifetime.Transient, ServiceLifetime.Transient
        );

        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(config => {
            config.SwaggerDoc("v1", new OpenApiInfo {
                Title = "Trippie API",
                Version = "v1",
                Description = "API for the Trippie mobile app"
            });

            // Include XML comments
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            config.IncludeXmlComments(xmlPath);
        });
        
        string localIpAddress = Utils.GetLocalIpAdress();

        builder.WebHost.ConfigureKestrel(options => {
            options.Listen(System.Net.IPAddress.Parse(localIpAddress), 5001, listenOptions => {
                listenOptions.UseHttps();
            });
            options.Listen(System.Net.IPAddress.Parse("127.0.0.1"), 5002, listenOptions => {
                listenOptions.UseHttps();
            });
        });

        builder.Services.AddAuthentication("jwtTokens")
            .AddJwtBearer("jwtTokens", options => {
                options.TokenValidationParameters = new TokenValidationParameters {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = builder.Configuration["Auth:JwtIssuer"],
                    ValidAudience = builder.Configuration["Auth:JwtAudience"],
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Auth:JwtSecretKey"]))
                };
                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];
                        var path = context.HttpContext.Request.Path;

                        if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                        {
                            context.Token = accessToken;
                        }

                        return Task.CompletedTask;
                    }
                };
            });

        builder.Services.AddAuthorization(options => {
            options.FallbackPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .Build();
        });

        builder.Services.AddCors(options =>
        {
            options.AddPolicy("SignalRPolicy", policy =>
            {
                policy
                    .WithOrigins(["https://127.0.0.1:*", $"https://{localIpAddress}:*"])
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials(); // required for SignalR
            });
        });
        builder.Services.AddHttpClient();
        builder.Services.AddServices();



        // Middleware pipeline
        var app = builder.Build();

        //Uncomment this only when you want to seed or migrate, otherwise leave commented
        // using (var scope = app.Services.CreateScope())
        // {
        //     var db = scope.ServiceProvider.GetRequiredService<TrippieContext>();
        //     await db.Database.MigrateAsync();
        //     await db.Database.EnsureCreatedAsync();
        // }
        
        app.Use(async (ctx, next) =>
        {
            try
            {
                await next();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[!] Unhandled: {ex}");
                ctx.Response.StatusCode = 500;
                ctx.Response.ContentType = "application/json";
                await ctx.Response.WriteAsJsonAsync(ApiResponse<object>.Failure(new ErrorDto
                {
                    Status = "error",
                    Code = 500,
                    Message = "[!] Internal server error. Check console for more information."
                }));
            }
        });

        if(app.Environment.IsDevelopment()) {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        app.UseAuthentication();

        app.UseAuthorization();

        app.UseCors("SignalRPolicy");
        app.MapHub<TripHub>("hubs/trip");
        
        app.MapControllers();

        app.Run();
    }
}
