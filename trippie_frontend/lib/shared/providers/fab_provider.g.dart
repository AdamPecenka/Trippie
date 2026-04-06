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
    extends $NotifierProvider<FabNotifier, Widget?> {
  FabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fabNotifierHash();

  @$internal
  @override
  FabNotifier create() => FabNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Widget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Widget?>(value),
    );
  }
}

String _$fabNotifierHash() => r'c3ecee5c9a1632cb1fe4cf032022493342c77624';

abstract class _$FabNotifier extends $Notifier<Widget?> {
  Widget? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Widget?, Widget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Widget?, Widget?>,
              Widget?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
