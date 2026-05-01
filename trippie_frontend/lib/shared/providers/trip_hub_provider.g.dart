// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_hub_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tripHub)
final tripHubProvider = TripHubProvider._();

final class TripHubProvider
    extends $FunctionalProvider<TripHubService, TripHubService, TripHubService>
    with $Provider<TripHubService> {
  TripHubProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripHubProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripHubHash();

  @$internal
  @override
  $ProviderElement<TripHubService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripHubService create(Ref ref) {
    return tripHub(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripHubService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripHubService>(value),
    );
  }
}

String _$tripHubHash() => r'e1099bcd63b808d9c59e23d5125656b7ceec5bd4';
