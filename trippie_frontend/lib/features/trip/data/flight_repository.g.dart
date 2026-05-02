// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(flightRepository)
final flightRepositoryProvider = FlightRepositoryProvider._();

final class FlightRepositoryProvider
    extends
        $FunctionalProvider<
          FlightRepository,
          FlightRepository,
          FlightRepository
        >
    with $Provider<FlightRepository> {
  FlightRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flightRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flightRepositoryHash();

  @$internal
  @override
  $ProviderElement<FlightRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlightRepository create(Ref ref) {
    return flightRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlightRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlightRepository>(value),
    );
  }
}

String _$flightRepositoryHash() => r'db42baa95a064249a3e955fd7fa99c87aad475d6';

@ProviderFor(tripFlights)
final tripFlightsProvider = TripFlightsFamily._();

final class TripFlightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlightDto>>,
          List<FlightDto>,
          FutureOr<List<FlightDto>>
        >
    with $FutureModifier<List<FlightDto>>, $FutureProvider<List<FlightDto>> {
  TripFlightsProvider._({
    required TripFlightsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripFlightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripFlightsHash();

  @override
  String toString() {
    return r'tripFlightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FlightDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FlightDto>> create(Ref ref) {
    final argument = this.argument as String;
    return tripFlights(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripFlightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripFlightsHash() => r'73b1247c876630e150aec0a287a49c13cbdc8f7d';

final class TripFlightsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FlightDto>>, String> {
  TripFlightsFamily._()
    : super(
        retry: null,
        name: r'tripFlightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripFlightsProvider call(String tripId) =>
      TripFlightsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripFlightsProvider';
}
