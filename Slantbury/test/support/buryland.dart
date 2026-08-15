import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slantbury/pieces/levels.dart';
import 'package:slantbury/pieces/play.dart';
import 'package:slantbury/ui/app.dart';
import 'package:slantbury/ui/frame_screen.dart';
import 'package:slantbury/ui/frameview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a frame, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SlantburyApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few frames only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

FrameScreenState state(WidgetTester tester) =>
    tester.state<FrameScreenState>(find.byType(FrameScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

Metrics metrics(WidgetTester tester) => Metrics(state(tester).play, board(tester).size);

/// Taps piece [p]'s tray slot.
Future<void> tapSlot(WidgetTester tester, int p) async {
  final room = board(tester);
  final m = metrics(tester);
  await tester.tapAt(room.topLeft + Offset(m.slotWidth * (p + 0.5), m.trayTop + m.trayHeight / 2));
  await tester.pumpAndSettle();
}

/// Taps the middle of the frame square ([x], [y]).
Future<void> tapSquare(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + metrics(tester).middleOf(x, y));
  await tester.pumpAndSettle();
}

/// Taps the middle of laid piece [p].
Future<void> tapLaid(WidgetTester tester, int p) async {
  final room = board(tester);
  final m = metrics(tester);
  final corners = state(tester).play.cornersOf(p)!;
  var at = Offset.zero;
  for (final c in corners) {
    at += m.at(c);
  }
  await tester.tapAt(room.topLeft + at / corners.length.toDouble());
  await tester.pumpAndSettle();
}

/// Lays every piece as the pointer says.
Future<void> layByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (what, p) = state(tester).pointing!;
    if (what == 'lift') {
      await tapLaid(tester, p);
      continue;
    }
    final target = Play.aimFor(state(tester).play.level)![p];
    await tapSquare(tester, target.x, target.y);
  }
}
