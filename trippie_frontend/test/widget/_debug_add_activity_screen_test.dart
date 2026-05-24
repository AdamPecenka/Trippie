import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippie_frontend/features/trip/presentation/add_activity_screen.dart';
import 'package:trippie_frontend/features/trip/data/trip_providers.dart';
import 'package:trippie_frontend/features/trip/data/trip_dto.dart';

class _FakeTripsNotifier extends TripsNotifier {
  @override
  Future<List<TripDto>> build() async => [];
}

Widget buildActivity({String tripId = 'test-trip'}) {
  return ProviderScope(
    overrides: [
      tripsProvider.overrideWith(_FakeTripsNotifier.new),
    ],
    child: MaterialApp(home: AddActivityScreen(tripId: tripId)),
  );
}

void main() {
  testWidgets('debug add activity tree', (tester) async {
    await tester.pumpWidget(buildActivity());
    await tester.pumpAndSettle();
    final materialApps = find.byType(MaterialApp).evaluate().length;
    final scaffolds = find.byType(Scaffold).evaluate().length;
    final textWidgets = find.byType(Text).evaluate();
    final textStrings = textWidgets
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    final elevatedButtons = find.byType(ElevatedButton).evaluate().length;
    final textButtons = find.byType(TextButton).evaluate().length;
    final buttons = find.byType(ButtonStyleButton).evaluate().length;
    print('materialApps=$materialApps scaffolds=$scaffolds texts=${textStrings.length}');
    print('texts=$textStrings');
    print('elevatedButtons=$elevatedButtons textButtons=$textButtons buttons=$buttons');
    expect(materialApps, greaterThan(0));
  });
}
