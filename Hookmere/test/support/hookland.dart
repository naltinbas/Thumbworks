import 'package:hookmere/shape/levels.dart';
import 'package:hookmere/ui/shape_screen.dart';
import 'package:hookmere/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:hookmere/ui/shapeview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const HookmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few asks only until it scrolls.
      await tester.scrollUntilVisible(tile, 80,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

ShapeScreenState state(WidgetTester tester) =>
    tester.state<ShapeScreenState>(find.byType(ShapeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a row sits on the screen, which is where a thumb goes.
Offset rowAt(WidgetTester tester, int row) {
  final where = board(tester);
  final m = Metrics(state(tester).play, where.size);
  return where.topLeft + Offset(m.left + m.cell * 0.5, m.top + m.cell * (row + 0.5));
}

/// Taps a row, which lifts a box off it or puts one down on it.
Future<void> tapRow(WidgetTester tester, int row) async {
  await tester.tapAt(rowAt(tester, row));
  await tester.pumpAndSettle();
}

/// Makes one move, lifting from a row and dropping on another.
Future<void> shift(WidgetTester tester, int from, int to) async {
  await tapRow(tester, from);
  await tapRow(tester, to);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (from, to) = state(tester).pointing!;
  await shift(tester, from, to);
}

/// Follows the pointer until the staircase lands, [most] moves at most.
Future<void> layByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
