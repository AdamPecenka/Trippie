using System.Diagnostics.CodeAnalysis;

namespace TrippieBackend.Models.Enums;

[SuppressMessage("ReSharper", "InconsistentNaming")]
public enum AppErrorEnum
{
    Email_Already_Exists,
    Phone_Already_Exists,
    Invalid_Credentials,
    Invalid_Refresh_Token,
    Refresh_Token_Expired,
    Refresh_Token_Revoked,
    Places_Autocomplete_Lat_Or_Lng_Not_Provided,
    Place_Not_Found,
    Destination_Place_Not_Found,
    Trip_Not_Found,
    Forbidden,
    Trip_Access_Denied,
    Trip_Manager_Required,
    Trip_Invalid_Status_Transition,
    Trip_Manager_Cannot_Leave,
    Accommodation_Not_Found,
    Accommodation_Already_Exists
}