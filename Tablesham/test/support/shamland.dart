import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablesham/table/parties.dart';
import 'package:tablesham/ui/app.dart';
import 'package:tablesham/ui/table_screen.dart';
import 'package:tablesham/ui/tableview.dart';

/// Opens the app on a party, or on the sham when [which] is
/// null.
Future<void> open(
  WidgetTester tester, {
  int? which,
  Size? screen,
}) async {
  SharedPreferences.setMockInitialValues({});
  if (screen != null) {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(const TableshamApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Parties.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

TableScreenState state(WidgetTester tester) =>
    tester.state<TableScreenState>(find.byType(TableScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The sham board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Picks a benched husband through the painter's metrics.
Future<void> pickBench(WidgetTester tester, int husband) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  final order = state(tester).play.bench.indexOf(husband);
  await tester.tapAt(room.topLeft + metrics.benchAt(order));
  await tester.pumpAndSettle();
}

/// Taps a gap's chair through the painter's metrics.
Future<void> tapGap(WidgetTester tester, int gap) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.gapAt(gap));
  await tester.pumpAndSettle();
}

/// Seats a husband in a gap.
Future<void> seat(WidgetTester tester, int husband, int gap) async {
  await pickBench(tester, husband);
  await tapGap(tester, gap);
}

/// Seats by the pointer until the party lands.
Future<void> partByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final (gap, husband) = state(tester).pointing!;
    if (state(tester).play.bench.contains(husband)) {
      await seat(tester, husband, gap);
    } else {
      await tapGap(tester, gap);
    }
  }
}
