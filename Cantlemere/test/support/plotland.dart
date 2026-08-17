import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cantlemere/plot/levels.dart';
import 'package:cantlemere/plot/rules.dart';
import 'package:cantlemere/ui/app.dart';
import 'package:cantlemere/ui/plot_screen.dart';
import 'package:cantlemere/ui/plotview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the field when [which] is null.
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
  await tester.pumpWidget(const CantlemereApp());
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

PlotScreenState state(WidgetTester tester) =>
    tester.state<PlotScreenState>(find.byType(PlotScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a peg is drawn, which is where a thumb goes.
Offset pegAt(WidgetTester tester, int x, int y) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).at(x, y);
}

/// A point well inside a laid plot, for a tap that lifts it off. A
/// plot's own middle can land exactly on a peg, and pegs are read first,
/// so this picks whichever inside point sits furthest from any of them.
Offset insideAt(WidgetTester tester, int plot) {
  final where = board(tester);
  final m = Metrics(state(tester).play, where.size);
  final corners = Rules.plots[plot];
  Offset weigh(double a, double b, double c) =>
      (m.spot(corners[0]) * a + m.spot(corners[1]) * b + m.spot(corners[2]) * c)
          / (a + b + c);
  Offset best = weigh(1, 1, 1);
  var clear = -1.0;
  for (final w in const [
    [1.0, 1.0, 1.0], [2.0, 1.0, 1.0], [1.0, 2.0, 1.0], [1.0, 1.0, 2.0],
    [3.0, 2.0, 2.0], [2.0, 3.0, 2.0], [2.0, 2.0, 3.0], [4.0, 3.0, 3.0],
  ]) {
    final at = weigh(w[0], w[1], w[2]);
    var away = double.infinity;
    for (var p = 0; p < Rules.pegs; p++) {
      final d = (m.spot(p) - at).distance;
      if (d < away) away = d;
    }
    if (away > clear) {
      clear = away;
      best = at;
    }
  }
  return where.topLeft + best;
}

/// Taps a peg by its two numbers.
Future<void> tapPeg(WidgetTester tester, int x, int y) async {
  await tester.tapAt(pegAt(tester, x, y));
  await tester.pumpAndSettle();
}

/// Lays a plot on three pegs.
Future<void> layPlot(WidgetTester tester, List<(int, int)> corners) async {
  for (final c in corners) {
    await tapPeg(tester, c.$1, c.$2);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final peg = state(tester).pointing!;
  final (x, y) = Rules.peg(peg);
  await tapPeg(tester, x, y);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> cutByPointer(WidgetTester tester, {int most = 24}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
