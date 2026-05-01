import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fab_provider.g.dart';

class FabAction {
  const FabAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

class FabState {
  const FabState({this.actions = const [], this.isOpen = false});
  final List<FabAction> actions;
  final bool isOpen;

  FabState copyWith({List<FabAction>? actions, bool? isOpen}) {
    return FabState(
      actions: actions ?? this.actions,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

@Riverpod(keepAlive: true)
class FabNotifier extends _$FabNotifier {
  @override
  FabState build() => const FabState();

  void setActions(List<FabAction> actions) {
    state = FabState(actions: actions, isOpen: false);
  }

  void toggle() => state = state.copyWith(isOpen: !state.isOpen);
  void close() => state = state.copyWith(isOpen: false);
  void clear() => state = const FabState();
}