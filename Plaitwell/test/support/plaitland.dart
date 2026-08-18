import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plaitwell/plait/levels.dart';
import 'package:plaitwell/ui/app.dart';
import 'package:plaitwell/ui/plait_screen.dart';
import 'package:plaitwell/ui/plaitview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the rope walk when [which] is null.
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
  await tester.pumpWidget(const PlaitwellApp());
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

PlaitScreenState state(WidgetTester tester) =>
    tester.state<PlaitScreenState>(find.byType(PlaitScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

Metrics metrics(WidgetTester tester) {
  final where = board(tester);
  return Metrics(state(tester).play, where.size);
}

/// Where a rope runs, which is where a thumb goes to dye it.
Offset ropeAt(WidgetTester tester, int arc) {
  final m = metrics(tester);
  final spot = m.holds().firstWhere((h) => h.$1 == arc);
  return board(tester).topLeft + spot.$2;
}

/// A point clear of every rope, which dyes nothing.
Offset boardAt(WidgetTester tester) {
  final where = board(tester);
  final m = metrics(tester);
  // The far left of the board, well clear of the leftmost lane.
  return where.topLeft + Offset(m.left - m.step * 1.4, m.top + m.step);
}

/// Dyes a rope one step on.
Future<void> dye(WidgetTester tester, int arc) async {
  await tester.tapAt(ropeAt(tester, arc));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> dyeByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await dye(tester, state(tester).play.next!);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> paintByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await dyeByPointer(tester);
  }
}
