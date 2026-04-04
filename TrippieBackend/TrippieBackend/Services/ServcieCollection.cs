using TrippieBackend.Services.IService;
using TrippieBackend.Services.Service;

namespace TrippieBackend.Services;

public static class ServiceCollection {
    public static IServiceCollection AddServices(this IServiceCollection services) {

        services.AddTransient<IUserService, UserService>();
        services.AddTransient<IAuthService, AuthService>();
        services.AddTransient<IAirportService, AirportService>();
        services.AddTransient<IPlaceService, PlaceService>();
        services.AddTransient<ITripService, TripService>();
        services.AddTransient<ITripMemberService, TripMemberService>();
        services.AddTransient<IAccommodationService, AccommodationService>();

        return services;
    }
}