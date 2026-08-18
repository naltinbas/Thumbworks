import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trestlemere/table/levels.dart';
import 'package:trestlemere/ui/app.dart';
import 'package:trestlemere/ui/table_screen.dart';
import 'package:trestlemere/ui/tableview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the hall when [which] is null.
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
  await tester.pumpWidget(const TrestlemereApp());
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

TableScreenState state(WidgetTester tester) =>
    tester.state<TableScreenState>(find.byType(TableScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a guest is drawn, which is where a thumb goes.
Offset guestAt(WidgetTester tester, int guest) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).seatOf(guest);
}

/// Where a trestle's board is drawn.
Offset trestleAt(WidgetTester tester, int trestle) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).boardOf(trestle).center;
}

/// Taps a guest, which picks them up or puts them down again.
Future<void> tapGuest(WidgetTester tester, int guest) async {
  await tester.tapAt(guestAt(tester, guest));
  await tester.pumpAndSettle();
}

/// Moves a guest to a trestle, which is two taps.
Future<void> move(WidgetTester tester, int guest, int trestle) async {
  await tapGuest(tester, guest);
  await tester.tapAt(trestleAt(tester, trestle));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).play.next!;
  await move(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] moves at most.
Future<void> seatByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
