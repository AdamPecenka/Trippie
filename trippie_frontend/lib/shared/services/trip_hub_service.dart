import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:trippie_frontend/shared/services/auth_service.dart';
import 'package:trippie_frontend/core/config/app_config.dart';

typedef HubEventHandler = void Function(List<Object?>? args);

class TripHubService {
  late final HubConnection connection;

  TripHubService(AuthService authService) {
    connection = HubConnectionBuilder()
        .withUrl(
          '${AppConfig.baseUrl}/hubs/trip',
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await authService.getAccessToken() ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();
  }

  Future<void> connect() async {
    if (connection.state == HubConnectionState.Disconnected) {
      await connection.start();
      debugPrint('[+] hub: connected');
    }
  }

  Future<void> disconnect() async {
    await connection.stop();
    debugPrint('[-] hub: disconnected');
  }

  Future<void> joinRoom(String tripId) async {
    await connection.invoke('trip:join_room', args: [tripId]);
    debugPrint('[+] hub: joined room $tripId');
  }

  Future<void> leaveRoom(String tripId) async {
    await connection.invoke('trip:leave_room', args: [tripId]);
    debugPrint('[-] hub: left room $tripId');
  }

  Future<void> updateLocation(String tripId, double latitude, double longitude) async {
    await connection.invoke(
      'location:update',
      args: [tripId, latitude, longitude],
    );
  }

  void on(String event, HubEventHandler handler) {
    connection.on(event, handler);
  }

  void off(String event) {
    connection.off(event);
  }

  void onMemberJoined(HubEventHandler handler) => on('trip:member_joined', handler);
  void onMemberLeft(HubEventHandler handler) => on('trip:member_left', handler);
  void onMemberDisconnected(HubEventHandler handler) => on('trip:member_disconnected', handler);
  void onLocationUpdated(HubEventHandler handler) => on('location:member_updated', handler);
  void onLocationOffline(HubEventHandler handler) => on('location:member_offline', handler);

  void offMemberJoined() => off('trip:member_joined');
  void offMemberLeft() => off('trip:member_left');
  void offMemberDisconnected() => off('trip:member_disconnected');
  void offLocationUpdated() => off('location:member_updated');
  void offLocationOffline() => off('location:member_offline');
}