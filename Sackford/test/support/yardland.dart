import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sackford/yard/levels.dart';
import 'package:sackford/ui/app.dart';
import 'package:sackford/ui/yard_screen.dart';
import 'package:sackford/ui/yardview.dart';
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
  await tester.pumpWidget(const SackfordApp());
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

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps sack [i] through the painter's metrics.
Future<void> tapSack(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.sackAt(i));
  await tester.pumpAndSettle();
}

/// Taps sack [i] until it rides in cart [c], or on the ground for null.
Future<void> putSack(WidgetTester tester, int i, int? c) async {
  var guard = 0;
  while (state(tester).play.cartOf[i] != c && guard++ < 6 && !state(tester).play.isOver) {
    await tapSack(tester, i);
  }
}

/// Loads the yard, a cart for each sack in order.
Future<void> load(WidgetTester tester, List<int?> carts) async {
  for (var i = 0; i < carts.length && !state(tester).play.isOver; i++) {
    await putSack(tester, i, carts[i]);
  }
}

/// Does what the pointer says, once.
Future<void> tapByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (i, taps) = state(tester).pointing!;
  for (var k = 0; k < taps; k++) {
    await tapSack(tester, i);
  }
}

/// Follows the pointer until the yard is loaded as asked.
Future<void> loadByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await tapByPointer(tester);
  }
}
