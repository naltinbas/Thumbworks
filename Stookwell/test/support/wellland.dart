import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stookwell/stook/levels.dart';
import 'package:stookwell/stook/play.dart';
import 'package:stookwell/ui/app.dart';
import 'package:stookwell/ui/stook_screen.dart';
import 'package:stookwell/ui/stookview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a harvest, or on the sham when [which] is null.
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
  await tester.pumpWidget(const StookwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

StookScreenState state(WidgetTester tester) =>
    tester.state<StookScreenState>(find.byType(StookScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the pool, beginning a stook, through the painter's metrics.
Future<void> tapPool(WidgetTester tester) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.poolAt);
  await tester.pumpAndSettle();
}

/// Taps stook row [i], standing one more sheaf in it.
Future<void> tapStook(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.rowAt(i));
  await tester.pumpAndSettle();
}

/// Stands a whole partition, stook by stook, largest first.
Future<void> stand(WidgetTester tester, List<int> parts) async {
  for (var i = 0; i < parts.length; i++) {
    await tapPool(tester);
    for (var k = 1; k < parts[i]; k++) {
      await tapStook(tester, i);
    }
  }
}

/// Stands by the pointer until the harvest lands.
Future<void> standByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (what, i) = state(tester).pointing!;
    if (what == 'back') {
      await press(tester, 'Back');
    } else if (what == 'new') {
      await tapPool(tester);
    } else {
      await tapStook(tester, i);
    }
  }
}

/// The tap that begins a stook, for tests that speak of it.
const newStook = Play.newStook;
