import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinderplot/best.dart';
import 'package:cinderplot/game/field.dart';
import 'package:cinderplot/ui/app.dart';
import 'package:cinderplot/ui/plot_painter.dart';
import 'package:cinderplot/ui/plot_screen.dart';

/// The bits every test that plays a board needs.
///
/// Nothing here stands in for the game. The screens are the real ones, the
/// board is laid out by the real maker, and a square is opened by tapping
/// where that square actually is.

/// A phone to lay a board out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  int? which,
  Field? opening,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    CinderplotApp(opensAt: which, opening: opening, best: best),
  );
  await tester.pump();
}

PlotScreenState state(WidgetTester tester) =>
    tester.state<PlotScreenState>(find.byType(PlotScreen));

Finder plot() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is PlotPainter,
    );

PlotPainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(plot().first).painter! as PlotPainter;

Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

/// The middle of a square, on the screen.
Offset onScreen(WidgetTester tester, int at) =>
    tester.getTopLeft(plot().first) + metricsOf(tester).squareAt(at).center;

Future<void> tapSquare(WidgetTester tester, int at) async {
  await tester.tapAt(onScreen(tester, at));
  await tester.pump();
}

Future<void> holdSquare(WidgetTester tester, int at) async {
  await tester.longPressAt(onScreen(tester, at));
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
}

/// The first shut square that is not a mine, for a test that wants to open
/// something without deciding what.
int aSafeShutSquare(WidgetTester tester) {
  final play = state(tester).play;
  for (var at = 0; at < play.field.cells; at++) {
    if (play.isShut(at) && !play.field.holdsMine(at)) return at;
  }
  throw StateError('nothing left to open');
}

/// The first shut square that is a mine.
int aMine(WidgetTester tester) {
  final play = state(tester).play;
  for (final at in play.field.mines) {
    if (play.isShut(at)) return at;
  }
  throw StateError('no mine left');
}
