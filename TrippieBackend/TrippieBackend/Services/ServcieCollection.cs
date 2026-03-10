using TrippieBackend.Services.IService;
using TrippieBackend.Services.Service;

namespace TrippieBackend.Services;

public static class ServiceCollection {
    public static IServiceCollection AddServices(this IServiceCollection services) {

        services.AddTransient<IUserService, UserService>();

        return services;
    }
}