import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharewick/trio/levels.dart';
import 'package:sharewick/trio/rules.dart';
import 'package:sharewick/ui/app.dart';
import 'package:sharewick/ui/trio_screen.dart';
import 'package:sharewick/ui/trioview.dart';
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
  await tester.pumpWidget(const SharewickApp());
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

TrioScreenState state(WidgetTester tester) =>
    tester.state<TrioScreenState>(find.byType(TrioScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the trio named [name] through the painter's metrics.
Future<void> tapTrio(WidgetTester tester, String name) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(Rules.trioOf(name)));
  await tester.pumpAndSettle();
}

/// Taps the trios named in turn.
Future<void> pickAll(WidgetTester tester, List<String> names) async {
  for (final n in names) {
    if (state(tester).play.isOver) return;
    await tapTrio(tester, n);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (trio, _) = state(tester).pointing!;
  await tapTrio(tester, Rules.nameOf(trio));
}

/// Follows the pointer until the family lands, [most] taps at most.
Future<void> pickByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
