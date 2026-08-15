import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusewick/fuse/levels.dart';
import 'package:fusewick/ui/app.dart';
import 'package:fusewick/ui/fuse_screen.dart';
import 'package:fusewick/ui/fuseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a time, or on the sham when [which] is null.
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
  await tester.pumpWidget(const FusewickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

FuseScreenState state(WidgetTester tester) =>
    tester.state<FuseScreenState>(find.byType(FuseScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Lights an end of a fuse through the painter's metrics.
Future<void> light(WidgetTester tester, int fuse, bool right) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.endAt(fuse, right));
  await tester.pumpAndSettle();
}

/// Taps the clock, letting the fuses burn to the next burnout.
Future<void> burn(WidgetTester tester) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.clock);
  await tester.pumpAndSettle();
}

/// Follows the pointer until the time is struck.
Future<void> strikeByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (what, fuse, right) = state(tester).pointing!;
    if (what == 'burn') {
      await burn(tester);
    } else {
      await light(tester, fuse, right);
    }
  }
}
