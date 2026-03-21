~~zacat pouzivat uuid ako primarne kluce~~
[] - pri zavreti aplikacie vyslat poslednu polohu do databazy, pri otvorenej aplikacii ju zdielat iba cez sockety
    [] - pri userovi ukazovat online/last seen na zaklade tohto

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

# Trippie API Endpoints

## REST

### Auth
- [ ] `POST /api/auth/register`
- [ ] `POST /api/auth/login`
- [ ] `POST /api/auth/logout`
- [ ] `POST /api/auth/refresh`

### Users
- [ ] `GET /api/users/me`
- [ ] `PUT /api/users/me`
- [ ] `DELETE /api/users/me`
- [ ] `PATCH /api/users/me/theme`
- [ ] `PUT /api/users/me/avatar`
- [ ] `GET /api/users/me/avatar`

### Trips
- [ ] `GET /api/trips`
- [ ] `POST /api/trips`
- [ ] `GET /api/trips/:tripId`
- [ ] `PATCH /api/trips/:tripId`
- [ ] `DELETE /api/trips/:tripId`
- [ ] `PATCH /api/trips/:tripId/status`

### Trip Members
- [ ] `GET /api/trips/:tripId/members`
- [ ] `DELETE /api/trips/:tripId/members/:userId`
- [ ] `DELETE /api/trips/:tripId/members/me`

### Invites
- [ ] `POST /api/trips/:tripId/invites`
- [ ] `GET /api/trips/:tripId/invites/:inviteCode/validate`
- [ ] `POST /api/trips/:tripId/invites/:inviteCode/join`

### Activities
- [ ] `GET /api/trips/:tripId/activities`
- [ ] `POST /api/trips/:tripId/activities`
- [ ] `GET /api/trips/:tripId/activities/:activityId`
- [ ] `PATCH /api/trips/:tripId/activities/:activityId`
- [ ] `DELETE /api/trips/:tripId/activities/:activityId`

### Accommodations
- [ ] `GET /api/trips/:tripId/accommodations`
- [ ] `POST /api/trips/:tripId/accommodations`
- [ ] `PATCH /api/trips/:tripId/accommodations/:accommodationId`
- [ ] `DELETE /api/trips/:tripId/accommodations/:accommodationId`

### Flights
- [ ] `GET /api/trips/:tripId/flights`
- [ ] `POST /api/trips/:tripId/flights`
- [ ] `PATCH /api/trips/:tripId/flights/:flightId`
- [ ] `DELETE /api/trips/:tripId/flights/:flightId`

### Location
- [ ] `GET /api/location/trips/:tripId/members`

### Favorites
- [ ] `GET /api/favorites`
- [ ] `POST /api/favorites`
- [ ] `DELETE /api/favorites/:placeId`

### Places
- [ ] `POST /api/places/resolve`
- [ ] `GET /api/places/:placeId`

### Airports
- [ ] `GET /api/airports?search=:query&limit=:n`

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