import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyloom/game/maker.dart';
import 'package:tallyloom/progress.dart';
import 'package:tallyloom/ui/app.dart';
import 'package:tallyloom/ui/board_painter.dart';
import 'package:tallyloom/ui/board_view.dart';
import 'package:tallyloom/ui/metrics.dart';

/// A phone to lay the game out on. The default is a middling one; the tests
/// that care about fitting pass their own.
const phone = Size(1170, 2532);

Future<Progress> saved([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
  return Progress(await SharedPreferences.getInstance());
}

/// Opens the game on a phone shaped screen.
Future<void> open(
  WidgetTester tester,
  Progress progress, {
  int? at,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(TallyloomApp(progress: progress, opensAt: at));
  await tester.pump();
}

/// Where the board thinks its squares are.
///
/// Read off the painter rather than worked out again here, so a test drags at
/// the squares the game is actually drawing. A test that computed its own
/// geometry would keep passing while the board drifted under the thumb.
Metrics metricsOf(WidgetTester tester) {
  final painted = tester
      .widgetList<CustomPaint>(find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(CustomPaint),
      ))
      .map((paint) => paint.painter)
      .whereType<BoardPainter>()
      .first;
  return painted.metrics;
}

Offset centreOf(WidgetTester tester, int row, int col) =>
    tester.getTopLeft(find.byType(BoardView)) +
    metricsOf(tester).squareAt(row, col).center;

/// Puts one square down.
Future<void> tapSquare(WidgetTester tester, int row, int col) async {
  await tester.tapAt(centreOf(tester, row, col));
  await tester.pump();
}

/// Draws a stroke from one square to another, the way a thumb does: down,
/// through every square on the way, up.
Future<void> stroke(
  WidgetTester tester,
  ({int row, int col}) from,
  ({int row, int col}) to,
) async {
  final gesture = await tester.startGesture(centreOf(tester, from.row, from.col));
  await tester.pump();

  final steps = (to.row - from.row).abs() + (to.col - from.col).abs();
  for (var step = 1; step <= steps; step++) {
    final row = from.row + ((to.row - from.row) * step / steps).round();
    final col = from.col + ((to.col - from.col) * step / steps).round();
    await gesture.moveTo(centreOf(tester, row, col));
    await tester.pump();
  }

  await gesture.up();
  await tester.pump();
}

/// Fills in the whole picture, one square at a time, which finishes the
/// puzzle. Slower than stroking it but it cannot go wrong, so a test about
/// something else can use it without being about this.
Future<void> drawThePicture(WidgetTester tester, Puzzle puzzle) async {
  for (var row = 0; row < puzzle.height; row++) {
    for (var col = 0; col < puzzle.width; col++) {
      if (!puzzle.picture.at(row, col)) continue;
      await tapSquare(tester, row, col);
    }
  }
}

/// Tells the game the phone went away, one lifecycle state at a time, because
/// a phone does not jump straight to paused and the framework refuses a
/// transition that skips a step.
Future<void> goAway(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }
}

Future<void> comeBack(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }
}
