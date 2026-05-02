// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_members_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberAvatar)
final memberAvatarProvider = MemberAvatarFamily._();

final class MemberAvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  MemberAvatarProvider._({
    required MemberAvatarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberAvatarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberAvatarHash();

  @override
  String toString() {
    return r'memberAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as String;
    return memberAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberAvatarHash() => r'ccacec6817585a8a897ecff4531d65f0eb6d794a';

final class MemberAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, String> {
  MemberAvatarFamily._()
    : super(
        retry: null,
        name: r'memberAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemberAvatarProvider call(String userId) =>
      MemberAvatarProvider._(argument: userId, from: this);

  @override
  String toString() => r'memberAvatarProvider';
}
