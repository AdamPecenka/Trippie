using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using System.Reflection;
using System.Text;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Services;

namespace TrippieBackend;

public class Program {
    public static void Main(string[] args) {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddControllers();

        builder.Services.AddEntityFrameworkNpgsql();
        builder.Services.AddDbContext<TrippieContext>(options =>
            options.UseNpgsql(builder.Configuration.GetConnectionString("TrippieConnectionString")),
                ServiceLifetime.Transient, ServiceLifetime.Transient
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

        var utils = new Utils();
        string localIpAddress = utils.GetLocalIpAdress();
        builder.WebHost.ConfigureKestrel(options => {
            options.Listen(System.Net.IPAddress.Parse(localIpAddress), 5001);
            options.Listen(System.Net.IPAddress.Parse(localIpAddress), 5002, listenOptions => {
                listenOptions.UseHttps();
            });
            options.Listen(System.Net.IPAddress.Parse("127.0.0.1"), 5003);
            options.Listen(System.Net.IPAddress.Parse("127.0.0.1"), 5004, listenOptions => {
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
                    ValidIssuer = "yourdomain.com",
                    ValidAudience = "yourdomain.com",
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["API:JwtSecretKey"]))
                };
            });

        builder.Services.AddAuthorization(options =>
        {
            options.FallbackPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .Build();
        });

        builder.Services.AddServices();



        // Middleware pipeline
        var app = builder.Build();

        if(app.Environment.IsDevelopment()) {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        app.UseAuthentication();

        app.UseAuthorization();

        app.MapControllers();

        app.Run();
    }
}
