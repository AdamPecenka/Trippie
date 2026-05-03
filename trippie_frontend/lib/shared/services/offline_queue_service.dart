import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OfflineOperation { create, update, delete }

class PendingActivity {
  final String localId;
  final OfflineOperation operation;
  final String tripId;
  final String? activityId; // required for update/delete
  final String? name;
  final String? placeId;
  final String? activityDate;
  final String? startTime;
  final String? endTime;
  final String? notes;

  PendingActivity({
    required this.localId,
    required this.operation,
    required this.tripId,
    this.activityId,
    this.name,
    this.placeId,
    this.activityDate,
    this.startTime,
    this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'operation': operation.name,
    'tripId': tripId,
    'activityId': activityId,
    'name': name,
    'placeId': placeId,
    'activityDate': activityDate,
    'startTime': startTime,
    'endTime': endTime,
    'notes': notes,
  };

  factory PendingActivity.fromJson(Map<String, dynamic> json) => PendingActivity(
    localId: json['localId'],
    operation: OfflineOperation.values.byName(json['operation']),
    tripId: json['tripId'],
    activityId: json['activityId'],
    name: json['name'],
    placeId: json['placeId'],
    activityDate: json['activityDate'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    notes: json['notes'],
  );
}

class OfflineQueueService {
  static const _key = 'pending_activities';

  Future<List<PendingActivity>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => PendingActivity.fromJson(jsonDecode(e))).toList();
  }

  Future<void> add(PendingActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(activity.toJson()));
    await prefs.setStringList(_key, raw);
    debugPrint('[+] offline queue: ${activity.operation.name} activity ${activity.localId}');
  }

  Future<void> remove(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['localId'] == localId;
    });
    await prefs.setStringList(_key, raw);
    debugPrint('[-] offline queue: removed $localId');
  }

  // When an activity is deleted offline while it also has a pending create,
  // we can just remove the create from the queue — no need to sync either.
  Future<void> cancelPendingCreate(String tripId, String activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['tripId'] == tripId &&
          decoded['activityId'] == activityId &&
          decoded['operation'] == OfflineOperation.create.name;
    });
    await prefs.setStringList(_key, raw);
  }
}