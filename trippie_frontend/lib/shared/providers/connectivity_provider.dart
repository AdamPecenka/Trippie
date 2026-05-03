import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
class IsOnline extends _$IsOnline {
  final _connectivity = Connectivity();

  @override
  bool build() {
    _init();
    return true; // optimistic default
  }

  void _init() async {
    // check current state immediately
    final result = await _connectivity.checkConnectivity();
    await _checkStatus(result.first);

    // listen for changes
    _connectivity.onConnectivityChanged.listen((results) async {
      await _checkStatus(results.first);
    });
  }

  Future<void> _checkStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      state = false;
      debugPrint('[i] connectivity: offline (no network)');
      return;
    }

    try {
      final lookup = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      state = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      state = false;
    } catch (_) {
      state = false;
    }

    debugPrint('[i] connectivity: ${state ? 'online' : 'offline (no reachability)'}');
  }
}