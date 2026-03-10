using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Services;
using TrippieBackend.Common;

namespace TrippieBackend;

public class Program {
    public static void Main(string[] args) {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddControllers();
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddOpenApi();

        builder.Services.AddEntityFrameworkNpgsql();
        builder.Services.AddDbContext<TrippieContext>(options =>
            options.UseNpgsql(builder.Configuration.GetConnectionString("TrippieConnectionString")),
                ServiceLifetime.Transient, ServiceLifetime.Transient
        );

        builder.Services.AddServices();

        var utils = new Utils();
        string localIpAddress = utils.GetLocalIpAdress();
        builder.WebHost.ConfigureKestrel(options => {
            // Http
            options.Listen(System.Net.IPAddress.Parse(localIpAddress), 5089);
            // Https
            options.Listen(System.Net.IPAddress.Parse(localIpAddress), 7244, listenOptions => {
                listenOptions.UseHttps();
            });
        });

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if(app.Environment.IsDevelopment()) {
            app.MapOpenApi();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();


        app.MapControllers();

        app.Run();
    }
}
