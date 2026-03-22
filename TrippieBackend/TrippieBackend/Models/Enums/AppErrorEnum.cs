namespace TrippieBackend.Models.Enums;

public enum AppErrorEnum
{
    EmailAlreadyExists,
    PhoneAlreadyExists,
    InvalidCredentials,
    InvalidRefreshToken,
    RefreshTokenExpired,
    RefreshTokenRevoked
}