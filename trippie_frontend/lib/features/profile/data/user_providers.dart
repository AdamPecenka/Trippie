import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippie_frontend/features/auth/data/auth_providers.dart';
import 'package:trippie_frontend/features/profile/data/user_repository.dart';

part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepository(apiService: ref.watch(apiServiceProvider));
}

@riverpod
Future<Uint8List?> userAvatar(Ref ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getAvatar();
}