namespace TrippieBackend.Models.DTOs.Favorites;

public class FavoriteDto
{
    public Guid Id { get; init; }
    public PlaceDto Place { get; init; }
}