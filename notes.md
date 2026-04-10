# Notes

- pri zavreti aplikacie vyslat poslednu polohu do databazy, pri otvorenej aplikacii ju zdielat iba cez sockety
    - pri userovi ukazovat online/last seen na zaklade tohto

- User is populated on every endpoint automatically. Just use it directly
    - `var userId = Utils.GetUserId(User)` 
        - User je tohto typu `public ClaimsPrincipal User { get; } in class Microsoft.AspNetCore.Mvc.ControllerBase`
- toto treba spustit pri kazdej zmene routera
    - `dart run build_runner build --delete-conflicting-outputs`

- Vytvaranie tripu zabezpecuju tri endpointy
    1. `POST /api/trips`
    2. `POST /api/trips/:tripId/accommodations`
    3. `POST /api/trips/:tripId/flights`
- na clientovi treba zabezpecit aby sa najprv vytvorilo jadro tripu, to navrati TripId a pomocou toho sa potom poslu zvysne dva endpointy

# Trippie API Endpoints

## REST

### Auth

- [x] `POST /api/auth/register`
- [x] `POST /api/auth/login`
- [x] `POST /api/auth/logout`
- [x] `POST /api/auth/refresh`
- [x] `POST /api/auth/google`

### Users

- [x] `GET /api/users/me`
- [x] `PUT /api/users/me` -> socketom update u ostatnych userov
~~- [ ] `DELETE /api/users/me` -> socketom update u ostatnych userov~~
- [x] `PATCH /api/users/me/theme` -> socketom update pre UserId
- [x] `PUT /api/users/me/avatar` -> socketom update u ostatnych userov
- [x] `GET /api/users/me/avatar`

### Trips

- [x] `GET /api/trips`
- [x] `POST /api/trips`
- [x] `GET /api/trips/:tripId`
- [x] `PATCH /api/trips/:tripId`
~~- [ ] `DELETE /api/trips/:tripId`~~
- [x] `PATCH /api/trips/:tripId/status` -> socketom update u ostatnych clenov tripu

### Trip Members

- [x] `GET /api/trips/:tripId/members`
- [x] `DELETE /api/trips/:tripId/members/me` -> socketom update u ostatnych clenov tripu

### Invites

- [x] `POST /api/trips/:tripId/invites` -> Socketom poslat invite
- [x] `POST /api/trips/:tripId/invites/:inviteCode/join` -> Socketom pridat do tripu, updatnut u vsetkych clenoch

### Activities

                    - Johannka

- [ ] `GET /api/trips/:tripId/activities`
- [ ] `POST /api/trips/:tripId/activities` -> socketom update u ostatnych clenov tripu
- [ ] `GET /api/trips/:tripId/activities/:activityId`
- [ ] `PATCH /api/trips/:tripId/activities/:activityId` -> socketom update u ostatnych clenov tripu
- [ ] `DELETE /api/trips/:tripId/activities/:activityId` -> socketom update u ostatnych clenov tripu

### Accommodations

- [x] `GET /api/trips/:tripId/accommodations`
- [x] `POST /api/trips/:tripId/accommodations`
- [x] `PATCH /api/trips/:tripId/accommodations/:accommodationId` -> socketom update u ostatnych clenov tripu
~~- [ ] `DELETE /api/trips/:tripId/accommodations/:accommodationId`~~

### Flights

- [ ] `GET /api/trips/:tripId/flights`                    - Johannka
- [ ] `POST /api/trips/:tripId/flights`                    - Johannka  
- [ ] `PATCH /api/trips/:tripId/flights/:flightId`                    - Johannka
- [ ] `DELETE /api/trips/:tripId/flights/:flightId`                    - Johannka

### Location

- Johannka
- [ ] `POST /api/location/trips/:tripId/me` -> Moja posledna lokacia pred odpojenim, inak cez socket y

### Favorites

- [ ] `GET /api/favorites`                     - Johannka
- [ ] `POST /api/favorites` -> Socketom pre UserId                     - Johannka
- [ ] `DELETE /api/favorites/:placeId`-> Socketom pre UserId                    - Johannka

### Places

- [x] `POST /api/places/resolve`
- [x] `GET /api/places/search?query=_&lat=_&lng=_`
- [ ] `GET /api/places/:placeId`                    - Johannka

### Airports

- [x] `GET /api/airports?search=:query&limit=:n`

---

## WebSocket

### Client → Server

- [ ] `trip:join_room`
- [ ] `trip:leave_room`
- [ ] `location:update`

### Server → Client

- [ ] `location:member_moved`
- [ ] `trip:member_joined`
- [ ] `trip:member_left`
- [ ] `trip:status_changed`
- [ ] `activity:created`
- [ ] `activity:updated`
- [ ] `activity:deleted`
- [ ] `invite:used`

# Doporucena folder structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_sizes.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── extensions/
│   │   └── datetime_ext.dart       # trip date formatting helpers
│   ├── utils/
│   │   └── qr_utils.dart
│   └── errors/
│       └── app_exception.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   └── loading_overlay.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── trip_enums.dart         # TripState (PLANNING/ACTIVE/FINISHED), TripRole (MANAGER/MEMBER), TransportType
│   └── services/
│       ├── api_service.dart        # base HTTP client
│       ├── auth_service.dart
│       └── location_service.dart   # live location, shared across map + members
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── auth_repository.dart
    │   │   └── auth_dto.dart
    │   └── presentation/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       └── splash_screen.dart
    │
    ├── trip/
    │   ├── data/
    │   │   ├── trip_repository.dart
    │   │   └── trip_dto.dart
    │   └── presentation/
    │       ├── home_screen.dart          # upcoming + finished trips list
    │       ├── create_trip_screen.dart   # destination, transport, dates
    │       ├── trip_detail_screen.dart   # itinerary per day, role-aware UI
    │       ├── trip_members_screen.dart  # member list + roles
    │       └── widgets/
    │           ├── trip_card.dart
    │           ├── day_plan_section.dart
    │           └── trip_state_badge.dart # PLANNING / ACTIVE / FINISHED chip
    │
    ├── activity/
    │   ├── data/
    │   │   ├── activity_repository.dart
    │   │   └── activity_dto.dart
    │   └── presentation/
    │       ├── add_activity_screen.dart
    │       ├── activity_detail_screen.dart
    │       └── widgets/
    │           └── activity_tile.dart
    │
    ├── invite/
    │   └── presentation/
    │       ├── invite_screen.dart        # QR code + link share
    │       └── scan_qr_screen.dart       # camera scanner to join trip
    │
    ├── map/
    │   ├── data/
    │   │   └── map_repository.dart       # fetch member locations, activity coords
    │   └── presentation/
    │       ├── map_screen.dart           # activity pins + live member locations
    │       └── widgets/
    │           ├── activity_map_marker.dart
    │           └── member_location_marker.dart
    │
    └── profile/
        ├── data/
        │   └── profile_repository.dart
        └── presentation/
            ├── profile_screen.dart
            ├── favorites_screen.dart     # saved/favourite places
            └── widgets/
                └── favorite_place_tile.dart
```

user types "Sagra..."
    → GET /api/places/search?query=Sagra
    → your backend calls Google autocomplete
    → returns list of suggestions (just google_place_id + display name, nothing stored)

user types "Sagrada..."
    → GET /api/places/search?query=Sagrada
    → same, nothing stored

user taps "Sagrada Família"
    → POST /api/places/resolve { "googlePlaceId": "ChIJ..." }
    → your backend calls Google for full details
    → stores in Places table if not already there
    → returns your internal Place with your UUID
    → that UUID is what gets saved on the Activity
