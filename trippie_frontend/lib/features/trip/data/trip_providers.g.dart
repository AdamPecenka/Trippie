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
