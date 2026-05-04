// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accommodation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accommodationRepository)
final accommodationRepositoryProvider = AccommodationRepositoryProvider._();

final class AccommodationRepositoryProvider
    extends
        $FunctionalProvider<
          AccommodationRepository,
          AccommodationRepository,
          AccommodationRepository
        >
    with $Provider<AccommodationRepository> {
  AccommodationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accommodationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accommodationRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccommodationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccommodationRepository create(Ref ref) {
    return accommodationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccommodationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccommodationRepository>(value),
    );
  }
}

String _$accommodationRepositoryHash() =>
    r'44fb75f5d28bf5ed37a2d05028588d4c35129e24';

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

String _$tripAccommodationHash() => r'ebf48deb2030ebc40e7e072ef01478c4cadb2076';

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
