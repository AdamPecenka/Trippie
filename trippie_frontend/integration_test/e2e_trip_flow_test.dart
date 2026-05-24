// integration_test/e2e_trip_flow_test.dart
// E2E-01: Vytvorenie tripu (Login → Create Trip → TripHubScreen)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippie_frontend/main.dart' as app;

import 'helpers/test_config.dart';

const _destination = 'Barcelona';
final  _tripName   = 'E2E Trip ${DateTime.now().millisecondsSinceEpoch}';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E-01: Používateľ sa prihlási a vytvorí nový trip',
      (tester) async {

    // ── KROK 1: Čerstvé tokeny cez HTTP ──────────────────────────────────────
    debugPrint('[E2E] Získavam čerstvé tokeny...');
    try {
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      final req = await client.postUrl(
        Uri.parse('${TestConfig.baseUrl}/api/auth/login'),
      );
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.write(jsonEncode({
        'email':    TestConfig.email,
        'password': TestConfig.password,
      }));
      final res  = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      debugPrint('[E2E] HTTP status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = (jsonDecode(body) as Map)['data'] as Map;
        const storage = FlutterSecureStorage();
        await storage.write(key: TestConfig.accessTokenKey,  value: data['accessToken']  as String);
        await storage.write(key: TestConfig.refreshTokenKey, value: data['refreshToken'] as String);
        debugPrint('[E2E] ✓ Tokeny zapísané');
      }
    } catch (e) {
      debugPrint('[E2E] ⚠ HTTP login zlyhal: $e — pokračujem s existujúcimi tokenmi');
    }

    // ── KROK 2: Spustenie app → HomeScreen ───────────────────────────────────
    app.main();

    await _waitFor(
      tester,
      condition: () => find.textContaining('Hello,').evaluate().isNotEmpty,
      description: 'HomeScreen',
      timeoutSeconds: 30,
    );
    expect(find.textContaining('Hello,'), findsOneWidget,
        reason: 'HomeScreen musí byť viditeľná');
    debugPrint('[E2E] ✓ HomeScreen');

    // ── KROK 3: FAB menu → Create trip ───────────────────────────────────────
    await _waitFor(
      tester,
      condition: () {
        final fabs = find.byType(FloatingActionButton).evaluate();
        if (fabs.isEmpty) return false;
        return (fabs.first.widget as FloatingActionButton).onPressed != null;
      },
      description: 'FAB enabled',
      timeoutSeconds: 5,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await _waitFor(
      tester,
      condition: () => find.text('Create trip').evaluate().isNotEmpty,
      description: 'FAB menu',
      timeoutSeconds: 5,
    );
    await tester.tap(find.text('Create trip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // ── KROK 4: CreateTripScreen ──────────────────────────────────────────────
    await _waitFor(
      tester,
      condition: () => find.text('New Trip').evaluate().isNotEmpty,
      description: 'CreateTripScreen',
      timeoutSeconds: 15,
    );
    expect(find.text('New Trip'), findsOneWidget);
    expect(find.text('Trip name *'), findsOneWidget);
    expect(find.text('Destination *'), findsOneWidget);
    expect(find.text('Dates *'), findsOneWidget);
    debugPrint('[E2E] ✓ CreateTripScreen');

    // ── KROK 5: Názov tripu ───────────────────────────────────────────────────
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Barcelona 2026'),
      _tripName,
    );
    await tester.pump();
    debugPrint('[E2E] ✓ Názov: $_tripName');

    // ── KROK 6: Destinácia ────────────────────────────────────────────────────
    await tester.tap(find.byType(TextField).at(1));
    await tester.enterText(find.byType(TextField).at(1), _destination);
    await tester.pump();

    await _waitFor(
      tester,
      condition: () => find.byType(ListTile).evaluate().isNotEmpty,
      description: 'Place suggestions',
      timeoutSeconds: 12,
    );
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('[E2E] ✓ Destinácia: $_destination');

    // ── KROK 7: Dátumy ────────────────────────────────────────────────────────
    await tester.tap(find.text('Select travel dates'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await _tapDay(tester, '25'); // May 25 — start
    await tester.pump(const Duration(milliseconds: 500));
    await _tapDay(tester, '28'); // May 28 — end
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Select travel dates'), findsNothing,
        reason: 'Dátumy musia byť vybrané');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    debugPrint('[E2E] ✓ Dátumy: May 25 – May 28');

    // ── KROK 8: Odoslanie formulára ───────────────────────────────────────────
    await tester.scrollUntilVisible(
      find.text('Create Trip →'), 150,
      scrollable: find.byType(Scrollable).first,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));

    final createBtn = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Create Trip →'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(createBtn.onPressed, isNotNull,
        reason: 'Tlačidlo Create Trip musí byť enabled');

    await tester.tap(find.text('Create Trip →'));
    await tester.pump();
    debugPrint('[E2E] ✓ Create Trip odoslané');

    // ── KROK 9: Overenie — TripHubScreen ─────────────────────────────────────
    await _waitFor(
      tester,
      condition: () => find.text('BOOKINGS').evaluate().isNotEmpty,
      description: 'TripHubScreen',
      timeoutSeconds: 15,
    );

    expect(find.text('BOOKINGS'), findsOneWidget,
        reason: 'TripHubScreen musí byť viditeľná po vytvorení tripu');
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Flights'), findsOneWidget);

    // Ostaň na TripHubScreen — viditeľný nový trip
    await tester.pump(const Duration(seconds: 2));

    debugPrint('[E2E] ✅ E2E-01 PASSED — Trip "$_tripName" úspešne vytvorený');
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> _waitFor(
  WidgetTester tester, {
  required bool Function() condition,
  required String description,
  int timeoutSeconds = 10,
}) async {
  for (int i = 0; i < timeoutSeconds * 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (condition()) return;
  }
  debugPrint('[E2E] ⚠ Timeout ($timeoutSeconds s): $description');
}

Future<void> _tapDay(WidgetTester tester, String day) async {
  final finder = find.text(day);
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.first);
    debugPrint('[E2E] Tapnutý deň $day');
  }
  await tester.pump();
}