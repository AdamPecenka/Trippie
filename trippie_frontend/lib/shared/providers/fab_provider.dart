import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fab_provider.g.dart';

@riverpod
class FabNotifier extends _$FabNotifier {
  @override
  Widget? build() {
    return null;
  }

  void set(Widget fab) {
    state = fab;
  }

  void clear() {
    state = null;
  }
}