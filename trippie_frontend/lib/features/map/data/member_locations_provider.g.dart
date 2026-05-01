// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberLocations)
final memberLocationsProvider = MemberLocationsProvider._();

final class MemberLocationsProvider
    extends $NotifierProvider<MemberLocations, Map<String, MemberLocation>> {
  MemberLocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberLocationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberLocationsHash();

  @$internal
  @override
  MemberLocations create() => MemberLocations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, MemberLocation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, MemberLocation>>(value),
    );
  }
}

String _$memberLocationsHash() => r'cd7bd922964b99a3923a2f0c1fdc80bd861b0261';

abstract class _$MemberLocations
    extends $Notifier<Map<String, MemberLocation>> {
  Map<String, MemberLocation> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, MemberLocation>, Map<String, MemberLocation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, MemberLocation>,
                Map<String, MemberLocation>
              >,
              Map<String, MemberLocation>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
