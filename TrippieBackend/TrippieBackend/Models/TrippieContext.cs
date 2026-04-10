using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;


namespace TrippieBackend.Models;

public class TrippieContext : DbContext
{
    public TrippieContext(DbContextOptions<TrippieContext> options)
        : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<TripMember> TripMembers => Set<TripMember>();
    public DbSet<Place> Places => Set<Place>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<TripInvite> TripInvites => Set<TripInvite>();
    public DbSet<Activity> Activities => Set<Activity>();
    public DbSet<Favorite> Favorites => Set<Favorite>();
    public DbSet<UserLastLocation> UserLastLocations => Set<UserLastLocation>();
    public DbSet<Flight> Flights => Set<Flight>();
    public DbSet<Accommodation> Accommodations => Set<Accommodation>();
    public DbSet<Airport> Airports => Set<Airport>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasPostgresEnum<ThemeEnum>();
        modelBuilder.HasPostgresEnum<TransportTypeEnum>();
        modelBuilder.HasPostgresEnum<TravelDirectionEnum>();
        modelBuilder.HasPostgresEnum<TripRoleEnum>();
        modelBuilder.HasPostgresEnum<TripStatusEnum>();

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
 
            entity.HasKey(u => u.Id);
            entity.Property(u => u.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(u => u.Firstname).HasColumnName("firstname").HasMaxLength(50).IsRequired();
            entity.Property(u => u.Lastname).HasColumnName("lastname").HasMaxLength(50).IsRequired();
            entity.Property(u => u.Email).HasColumnName("email").HasMaxLength(320).IsRequired();
            entity.Property(u => u.PhoneNumber).HasColumnName("phone_number").HasMaxLength(20);
            entity.Property(u => u.PasswordHash).HasColumnName("password_hash").IsRequired();
            entity.Property(u => u.Theme).HasColumnName("theme").HasDefaultValue(ThemeEnum.LIGHT);
            entity.Property(u => u.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(u => u.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
            entity.Property(u => u.AvatarPath).HasColumnName("avatar_path");
            
            entity.HasIndex(u => u.Email).IsUnique();
            entity.HasIndex(u => u.PhoneNumber).IsUnique();
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.ToTable("refresh_tokens");

            entity.HasKey(r => r.Id);
            entity.Property(r => r.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");

            entity.Property(r => r.UserId).HasColumnName("user_id").IsRequired();
            entity.Property(r => r.TokenValue).HasColumnName("token_value").IsRequired();
            entity.Property(r => r.ExpiresAt).HasColumnName("expires_at").IsRequired();
            entity.Property(r => r.Revoked).HasColumnName("revoked").IsRequired();
            entity.Property(r => r.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(r => r.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");

            entity.HasIndex(r => r.UserId).HasDatabaseName("idx_refresh_tokens_user_id");

            entity.HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .HasConstraintName("fk_refresh_tokens_user")
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Place>(entity =>
        {
            entity.ToTable("places");

            entity.HasKey(p => p.Id);
            entity.Property(p => p.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");

            entity.Property(p => p.Name).HasColumnName("name").HasMaxLength(255).IsRequired();
            entity.Property(p => p.Address).HasColumnName("address");
            entity.Property(p => p.City).HasColumnName("city").HasMaxLength(255);
            entity.Property(p => p.Country).HasColumnName("country").HasMaxLength(255);
            entity.Property(p => p.Latitude).HasColumnName("latitude").HasColumnType("double precision").IsRequired();
            entity.Property(p => p.Longitude).HasColumnName("longitude").HasColumnType("double precision").IsRequired();
            entity.Property(p => p.GooglePlaceId).HasColumnName("google_place_id").HasMaxLength(255);
            entity.Property(p => p.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(p => p.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");

            entity.HasIndex(p => p.GooglePlaceId).IsUnique();
        });
 
        modelBuilder.Entity<Trip>(entity =>
        {
            entity.ToTable("trips");
 
            entity.HasKey(t => t.Id);
            entity.Property(t => t.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(t => t.Name).HasColumnName("name").HasMaxLength(255).IsRequired();
            entity.Property(t => t.DestinationPlaceId).HasColumnName("destination_place_id");
            entity.Property(t => t.TransportType).HasColumnName("transport_type").IsRequired();
            entity.Property(t => t.TripStatus).HasColumnName("trip_status").HasDefaultValue(TripStatusEnum.PLANNING);
            entity.Property(t => t.StartDate).HasColumnName("start_date").IsRequired();
            entity.Property(t => t.EndDate).HasColumnName("end_date").IsRequired();
            entity.Property(t => t.CreatedBy).HasColumnName("created_by").IsRequired();
            entity.Property(t => t.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(t => t.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasOne(t => t.Creator)
                .WithMany(u => u.CreatedTrips)
                .HasForeignKey(t => t.CreatedBy)
                .HasConstraintName("fk_trip_creator")
                .OnDelete(DeleteBehavior.Restrict);
 
            entity.HasOne(t => t.DestinationPlace)
                .WithMany(p => p.Trips)
                .HasForeignKey(t => t.DestinationPlaceId)
                .HasConstraintName("fk_trip_destination")
                .OnDelete(DeleteBehavior.SetNull);
        });
        
        modelBuilder.Entity<TripMember>(entity =>
        {
            entity.ToTable("trip_members");
 
            entity.HasKey(tm => tm.Id);
            entity.Property(tm => tm.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(tm => tm.TripId).HasColumnName("trip_id").IsRequired();
            entity.Property(tm => tm.UserId).HasColumnName("user_id").IsRequired();
            entity.Property(tm => tm.TripRole).HasColumnName("trip_role").IsRequired();
            entity.Property(tm => tm.JoinedAt).HasColumnName("joined_at").IsRequired();
            entity.Property(tm => tm.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(tm => tm.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasIndex(tm => new { tm.TripId, tm.UserId })
                .IsUnique()
                .HasDatabaseName("uq_trip_members");
 
            entity.HasOne(tm => tm.Trip)
                .WithMany(t => t.Members)
                .HasForeignKey(tm => tm.TripId)
                .HasConstraintName("fk_trip_members_trip")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(tm => tm.User)
                .WithMany(u => u.TripMemberships)
                .HasForeignKey(tm => tm.UserId)
                .HasConstraintName("fk_trip_members_user")
                .OnDelete(DeleteBehavior.Cascade);
        });
        
        modelBuilder.Entity<TripInvite>(entity =>
        {
            entity.ToTable("trip_invites");
 
            entity.HasKey(ti => ti.Id);
            entity.Property(ti => ti.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(ti => ti.TripId).HasColumnName("trip_id");
            entity.Property(i => i.InviteCode).HasColumnName("invite_code").HasColumnType("integer");
            entity.Property(ti => ti.CreatedBy).HasColumnName("created_by");
            entity.Property(ti => ti.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(ti => ti.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasIndex(ti => ti.InviteCode).IsUnique();
 
            entity.HasOne(ti => ti.Trip)
                .WithMany()
                .HasForeignKey(ti => ti.TripId)
                .HasConstraintName("fk_trip_invites_trip")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(ti => ti.Creator)
                .WithMany()
                .HasForeignKey(ti => ti.CreatedBy)
                .HasConstraintName("fk_trip_invites_creator")
                .OnDelete(DeleteBehavior.SetNull);
        });
 
        modelBuilder.Entity<Activity>(entity =>
        {
            entity.ToTable("activities");
 
            entity.HasKey(a => a.Id);
            entity.Property(a => a.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(a => a.TripId).HasColumnName("trip_id");
            entity.Property(a => a.PlaceId).HasColumnName("place_id");
            entity.Property(a => a.Name).HasColumnName("name").HasMaxLength(100);
            entity.Property(a => a.ActivityDate).HasColumnName("activity_date");
            entity.Property(a => a.StartTime).HasColumnName("start_time");
            entity.Property(a => a.EndTime).HasColumnName("end_time");
            entity.Property(a => a.Notes).HasColumnName("notes");
            entity.Property(a => a.CreatedBy).HasColumnName("created_by");
            entity.Property(a => a.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(a => a.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasOne(a => a.Trip)
                .WithMany()
                .HasForeignKey(a => a.TripId)
                .HasConstraintName("fk_activities_trip")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(a => a.Place)
                .WithMany()
                .HasForeignKey(a => a.PlaceId)
                .HasConstraintName("fk_activities_place")
                .OnDelete(DeleteBehavior.SetNull);
 
            entity.HasOne(a => a.Creator)
                .WithMany()
                .HasForeignKey(a => a.CreatedBy)
                .HasConstraintName("fk_activities_creator")
                .OnDelete(DeleteBehavior.SetNull);
        });
 
        modelBuilder.Entity<Favorite>(entity =>
        {
            entity.ToTable("favorites");
 
            entity.HasKey(f => f.Id);
            entity.Property(f => f.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(f => f.UserId).HasColumnName("user_id");
            entity.Property(f => f.PlaceId).HasColumnName("place_id");
            entity.Property(f => f.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(f => f.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasIndex(f => new { f.UserId, f.PlaceId })
                .IsUnique()
                .HasDatabaseName("uq_favorites");
 
            entity.HasOne(f => f.User)
                .WithMany()
                .HasForeignKey(f => f.UserId)
                .HasConstraintName("fk_favorites_user")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(f => f.Place)
                .WithMany()
                .HasForeignKey(f => f.PlaceId)
                .HasConstraintName("fk_favorites_place")
                .OnDelete(DeleteBehavior.Cascade);
        });
 
        modelBuilder.Entity<UserLastLocation>(entity =>
        {
            entity.ToTable("user_last_location");
 
            entity.HasKey(ull => new { ull.UserId, ull.TripId });
 
            entity.Property(ull => ull.UserId).HasColumnName("user_id");
            entity.Property(ull => ull.TripId).HasColumnName("trip_id");
            entity.Property(ull => ull.Latitude).HasColumnName("latitude").HasColumnType("double precision");
            entity.Property(ull => ull.Longitude).HasColumnName("longitude").HasColumnType("double precision");
            entity.Property(ull => ull.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(ull => ull.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasOne(ull => ull.User)
                .WithMany()
                .HasForeignKey(ull => ull.UserId)
                .HasConstraintName("fk_user_last_location_user")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(ull => ull.Trip)
                .WithMany()
                .HasForeignKey(ull => ull.TripId)
                .HasConstraintName("fk_user_last_location_trip")
                .OnDelete(DeleteBehavior.Cascade);
        });
 
        modelBuilder.Entity<Flight>(entity =>
        {
            entity.ToTable("flights");

            entity.HasKey(f => f.Id);
            entity.Property(f => f.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");

            entity.Property(f => f.TripId).HasColumnName("trip_id").IsRequired();
            entity.Property(f => f.TravelDirection).HasColumnName("travel_direction").IsRequired();
            entity.Property(f => f.FlightNumber).HasColumnName("flight_number").HasMaxLength(20);
            entity.Property(f => f.DepartureAirportId).HasColumnName("departure_airport_id").IsRequired();
            entity.Property(f => f.ArrivalAirportId).HasColumnName("arrival_airport_id").IsRequired();
            entity.Property(f => f.DepartureTime).HasColumnName("departure_time");
            entity.Property(f => f.ArrivalTime).HasColumnName("arrival_time");
            entity.Property(f => f.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(f => f.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");

            entity.HasOne(f => f.Trip)
                .WithMany()
                .HasForeignKey(f => f.TripId)
                .HasConstraintName("fk_flights_trip")
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(f => f.DepartureAirport)
                .WithMany()
                .HasForeignKey(f => f.DepartureAirportId)
                .HasConstraintName("fk_flights_departure_airport")
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(f => f.ArrivalAirport)
                .WithMany()
                .HasForeignKey(f => f.ArrivalAirportId)
                .HasConstraintName("fk_flights_arrival_airport")
                .OnDelete(DeleteBehavior.Restrict);
        });
        
        modelBuilder.Entity<Accommodation>(entity =>
        {
            entity.ToTable("accommodations");
 
            entity.HasKey(a => a.Id);
            entity.Property(a => a.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
 
            entity.Property(a => a.TripId).HasColumnName("trip_id");
            entity.Property(a => a.PlaceId).HasColumnName("place_id");
            entity.Property(a => a.CheckIn).HasColumnName("check_in");
            entity.Property(a => a.CheckOut).HasColumnName("check_out");
            entity.Property(a => a.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("now()");
            entity.Property(a => a.UpdatedAt).HasColumnName("updated_at").HasDefaultValueSql("now()");
 
            entity.HasOne(a => a.Trip)
                .WithMany()
                .HasForeignKey(a => a.TripId)
                .HasConstraintName("fk_accommodations_trip")
                .OnDelete(DeleteBehavior.Cascade);
 
            entity.HasOne(a => a.Place)
                .WithMany()
                .HasForeignKey(a => a.PlaceId)
                .HasConstraintName("fk_accommodations_place")
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Airport>(e =>
        {
            e.ToTable("airports");

            e.HasKey(a => a.Id);
            e.Property(a => a.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            e.Property(a => a.Name).HasColumnName("name").HasMaxLength(255).IsRequired();
            e.Property(a => a.City).HasColumnName("city").HasMaxLength(255).IsRequired();
            e.Property(a => a.Country).HasColumnName("country").HasMaxLength(255).IsRequired();
            e.Property(a => a.IataCode).HasColumnName("iata_code").HasMaxLength(3).IsRequired();
            e.Property(a => a.Latitude).HasColumnName("latitude").HasColumnType("double precision").IsRequired();
            e.Property(a => a.Longitude).HasColumnName("longitude").HasColumnType("double precision").IsRequired();
            e.Property(a => a.Timezone).HasColumnName("timezone").HasColumnType("decimal(5,2)").IsRequired();

            e.HasIndex(a => a.IataCode).IsUnique();
        });
    }
}