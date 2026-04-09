using System.Diagnostics.CodeAnalysis;

namespace TrippieBackend.Models.Enums;

[SuppressMessage("ReSharper", "InconsistentNaming")]
public enum AppErrorEnum
{
    // --- Auth ---
    Email_Already_Exists,
    Phone_Already_Exists,
    Invalid_Credentials,
    Invalid_Refresh_Token,
    Refresh_Token_Expired,
    Refresh_Token_Revoked,

    // --- Places ---
    Places_Autocomplete_Lat_Or_Lng_Not_Provided,
    Place_Not_Found,
    Destination_Place_Not_Found,

    // --- Trips ---
    Trip_Not_Found,
    Trip_Access_Denied,
    Trip_Manager_Required,
    Trip_Invalid_Status_Transition,
    Trip_Already_Finished,

    // --- Trip Members ---
    Trip_Manager_Cannot_Leave,
    Trip_Already_Member,

    // --- Accommodations ---
    Accommodation_Not_Found,
    Accommodation_Already_Exists,

    // --- Invites ---
    Invite_Invalid_Code,
    
    // --- Avatar ---
    Avatar_Invalid_Format,
    Avatar_Too_Large,
    Avatar_Not_Found,
    
    // --- General ---
    Forbidden,
    
    // --- Activities ---
    Activity_Not_Found,
    
    // --- Airport ---
    Airport_Not_Found,
    
    // --- Flights ---
    Flight_Not_Found
}