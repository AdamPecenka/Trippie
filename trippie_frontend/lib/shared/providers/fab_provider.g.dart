// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FabNotifier)
final fabProvider = FabNotifierProvider._();

final class FabNotifierProvider
    extends $NotifierProvider<FabNotifier, FabState> {
  FabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fabNotifierHash();

  @$internal
  @override
  FabNotifier create() => FabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FabState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FabState>(value),
    );
  }
}

String _$fabNotifierHash() => r'67b77037c04058a03adcefca775a132ec2f8c5fa';

abstract class _$FabNotifier extends $Notifier<FabState> {
  FabState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FabState, FabState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FabState, FabState>,
              FabState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
