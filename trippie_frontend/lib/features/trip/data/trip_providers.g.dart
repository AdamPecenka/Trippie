// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tripRepository)
final tripRepositoryProvider = TripRepositoryProvider._();

final class TripRepositoryProvider
    extends $FunctionalProvider<TripRepository, TripRepository, TripRepository>
    with $Provider<TripRepository> {
  TripRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRepository create(Ref ref) {
    return tripRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRepository>(value),
    );
  }
}

String _$tripRepositoryHash() => r'08f378385f17dacf141d571fb4ccd361636ada46';

@ProviderFor(TripsNotifier)
final tripsProvider = TripsNotifierProvider._();

final class TripsNotifierProvider
    extends $AsyncNotifierProvider<TripsNotifier, List<TripDto>> {
  TripsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripsNotifierHash();

  @$internal
  @override
  TripsNotifier create() => TripsNotifier();
}

String _$tripsNotifierHash() => r'a80fa286da33c590116fba00393e3e1bb4e78eb7';

abstract class _$TripsNotifier extends $AsyncNotifier<List<TripDto>> {
  FutureOr<List<TripDto>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TripDto>>, List<TripDto>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TripDto>>, List<TripDto>>,
              AsyncValue<List<TripDto>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(activeTrips)
final activeTripsProvider = ActiveTripsProvider._();

final class ActiveTripsProvider
    extends $FunctionalProvider<List<TripDto>, List<TripDto>, List<TripDto>>
    with $Provider<List<TripDto>> {
  ActiveTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTripsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTripsHash();

  @$internal
  @override
  $ProviderElement<List<TripDto>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TripDto> create(Ref ref) {
    return activeTrips(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TripDto> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TripDto>>(value),
    );
  }
}

String _$activeTripsHash() => r'4c28ccb911dd22479aad6b0642375460787718f3';

@ProviderFor(activeTripMembers)
final activeTripMembersProvider = ActiveTripMembersFamily._();

final class ActiveTripMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TripMemberDto>>,
          List<TripMemberDto>,
          FutureOr<List<TripMemberDto>>
        >
    with
        $FutureModifier<List<TripMemberDto>>,
        $FutureProvider<List<TripMemberDto>> {
  ActiveTripMembersProvider._({
    required ActiveTripMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeTripMembersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeTripMembersHash();

  @override
  String toString() {
    return r'activeTripMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TripMemberDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TripMemberDto>> create(Ref ref) {
    final argument = this.argument as String;
    return activeTripMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTripMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeTripMembersHash() => r'1661d3e482b51c4de8ca8cec8c6bb086e3345ad0';

final class ActiveTripMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TripMemberDto>>, String> {
  ActiveTripMembersFamily._()
    : super(
        retry: null,
        name: r'activeTripMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActiveTripMembersProvider call(String tripId) =>
      ActiveTripMembersProvider._(argument: tripId, from: this);

  @override
  String toString() => r'activeTripMembersProvider';
}

@ProviderFor(activeTripActivities)
final activeTripActivitiesProvider = ActiveTripActivitiesFamily._();

final class ActiveTripActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActivityDto>>,
          List<ActivityDto>,
          FutureOr<List<ActivityDto>>
        >
    with
        $FutureModifier<List<ActivityDto>>,
        $FutureProvider<List<ActivityDto>> {
  ActiveTripActivitiesProvider._({
    required ActiveTripActivitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeTripActivitiesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeTripActivitiesHash();

  @override
  String toString() {
    return r'activeTripActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ActivityDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActivityDto>> create(Ref ref) {
    final argument = this.argument as String;
    return activeTripActivities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTripActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeTripActivitiesHash() =>
    r'76898f14cc2a5ad5191733215ef5c7b6c5a41cc3';

final class ActiveTripActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ActivityDto>>, String> {
  ActiveTripActivitiesFamily._()
    : super(
        retry: null,
        name: r'activeTripActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActiveTripActivitiesProvider call(String tripId) =>
      ActiveTripActivitiesProvider._(argument: tripId, from: this);

  @override
  String toString() => r'activeTripActivitiesProvider';
}

@ProviderFor(activeTripAccommodation)
final activeTripAccommodationProvider = ActiveTripAccommodationFamily._();

final class ActiveTripAccommodationProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccommodationDto?>,
          AccommodationDto?,
          FutureOr<AccommodationDto?>
        >
    with
        $FutureModifier<AccommodationDto?>,
        $FutureProvider<AccommodationDto?> {
  ActiveTripAccommodationProvider._({
    required ActiveTripAccommodationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeTripAccommodationProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeTripAccommodationHash();

  @override
  String toString() {
    return r'activeTripAccommodationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AccommodationDto?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccommodationDto?> create(Ref ref) {
    final argument = this.argument as String;
    return activeTripAccommodation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTripAccommodationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeTripAccommodationHash() =>
    r'db351a3d3e32515f5ccb938b1238e44898d0d755';

final class ActiveTripAccommodationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AccommodationDto?>, String> {
  ActiveTripAccommodationFamily._()
    : super(
        retry: null,
        name: r'activeTripAccommodationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActiveTripAccommodationProvider call(String tripId) =>
      ActiveTripAccommodationProvider._(argument: tripId, from: this);

  @override
  String toString() => r'activeTripAccommodationProvider';
}

@ProviderFor(tripActivities)
final tripActivitiesProvider = TripActivitiesFamily._();

final class TripActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActivityDto>>,
          List<ActivityDto>,
          FutureOr<List<ActivityDto>>
        >
    with
        $FutureModifier<List<ActivityDto>>,
        $FutureProvider<List<ActivityDto>> {
  TripActivitiesProvider._({
    required TripActivitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripActivitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripActivitiesHash();

  @override
  String toString() {
    return r'tripActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ActivityDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActivityDto>> create(Ref ref) {
    final argument = this.argument as String;
    return tripActivities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripActivitiesHash() => r'3d177a54eff61e5c24cfbfe8eed94f3ea3499c8b';

final class TripActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ActivityDto>>, String> {
  TripActivitiesFamily._()
    : super(
        retry: null,
        name: r'tripActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripActivitiesProvider call(String tripId) =>
      TripActivitiesProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripActivitiesProvider';
}

@ProviderFor(tripMembers)
final tripMembersProvider = TripMembersFamily._();

final class TripMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TripMemberDto>>,
          List<TripMemberDto>,
          FutureOr<List<TripMemberDto>>
        >
    with
        $FutureModifier<List<TripMemberDto>>,
        $FutureProvider<List<TripMemberDto>> {
  TripMembersProvider._({
    required TripMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripMembersHash();

  @override
  String toString() {
    return r'tripMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TripMemberDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TripMemberDto>> create(Ref ref) {
    final argument = this.argument as String;
    return tripMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripMembersHash() => r'35f445160301e93677bd91e8c6057bd5e8c8f817';

final class TripMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TripMemberDto>>, String> {
  TripMembersFamily._()
    : super(
        retry: null,
        name: r'tripMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripMembersProvider call(String tripId) =>
      TripMembersProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripMembersProvider';
}

@ProviderFor(tripAccommodation)
final tripAccommodationProvider = TripAccommodationFamily._();

final class TripAccommodationProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccommodationDto?>,
          AccommodationDto?,
          FutureOr<AccommodationDto?>
        >
    with
        $FutureModifier<AccommodationDto?>,
        $FutureProvider<AccommodationDto?> {
  TripAccommodationProvider._({
    required TripAccommodationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripAccommodationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripAccommodationHash();

  @override
  String toString() {
    return r'tripAccommodationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AccommodationDto?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccommodationDto?> create(Ref ref) {
    final argument = this.argument as String;
    return tripAccommodation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripAccommodationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripAccommodationHash() => r'0be22936bda01706e5f6dabab980109a8e54680e';

final class TripAccommodationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AccommodationDto?>, String> {
  TripAccommodationFamily._()
    : super(
        retry: null,
        name: r'tripAccommodationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripAccommodationProvider call(String tripId) =>
      TripAccommodationProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripAccommodationProvider';
}
