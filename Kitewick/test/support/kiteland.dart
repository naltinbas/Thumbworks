import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitewick/kite/levels.dart';
import 'package:kitewick/kite/play.dart';
import 'package:kitewick/ui/app.dart';
import 'package:kitewick/ui/kite_screen.dart';
import 'package:kitewick/ui/kiteview.dart';
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
  await tester.pumpWidget(const KitewickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

KiteScreenState state(WidgetTester tester) =>
    tester.state<KiteScreenState>(find.byType(KiteScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps kite cell [i] through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.rect(i).center);
  await tester.pumpAndSettle();
}

/// Lays a slate over cells [a] and [b], two taps.
Future<void> lay(WidgetTester tester, int a, int b) async {
  await tapCell(tester, a);
  await tapCell(tester, b);
}

/// Lays every slate of [slates].
Future<void> layAll(WidgetTester tester, List<(int, int)> slates) async {
  for (final (a, b) in slates) {
    await lay(tester, a, b);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, cell) = state(tester).pointing!;
  switch (aim) {
    case Aim.pick:
    case Aim.lay:
    case Aim.lift:
      await tapCell(tester, cell);
  }
}

/// Follows the pointer until the kite is slated, [most] steps at most.
Future<void> slateByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
