import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgeworth/stack/levels.dart';
import 'package:ledgeworth/ui/app.dart';
import 'package:ledgeworth/ui/stack_screen.dart';
import 'package:ledgeworth/ui/stackview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a stack, or on the sham when [which] is null.
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
  await tester.pumpWidget(const LedgeworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

StackScreenState state(WidgetTester tester) =>
    tester.state<StackScreenState>(find.byType(StackScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Nudges book [i] by [by], one twenty-fourth, through the painter's
/// metrics: the right half for out, the left half for back.
Future<void> nudge(WidgetTester tester, int i, int by) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.half(i, by));
  await tester.pumpAndSettle();
}

/// Nudges book [i] out [times] twenty-fourths.
Future<void> nudgeOut(WidgetTester tester, int i, int times) async {
  for (var k = 0; k < times; k++) {
    await nudge(tester, i, 1);
  }
}

/// Leans the whole stack to the offsets given, top first.
Future<void> lean(WidgetTester tester, List<int> offsets) async {
  for (var i = 0; i < offsets.length; i++) {
    await nudgeOut(tester, i, offsets[i]);
  }
}

/// Leans by the pointer until the stack lands.
Future<void> leanByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (what, i) = state(tester).pointing!;
    await nudge(tester, i, what == 'right' ? 1 : -1);
  }
}
