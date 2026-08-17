import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodwell/rod/levels.dart';
import 'package:rodwell/ui/app.dart';
import 'package:rodwell/ui/rod_screen.dart';
import 'package:rodwell/ui/rodview.dart';
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
  await tester.pumpWidget(const RodwellApp());
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

RodScreenState state(WidgetTester tester) =>
    tester.state<RodScreenState>(find.byType(RodScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Cuts the rod after hand [place] + 1, or mends that cut.
Future<void> cutAt(WidgetTester tester, int place) async {
  final room = board(tester);
  final m = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + Offset(m.cutAt(place), m.middle));
  await tester.pumpAndSettle();
}

/// Cuts the rod at each of [places] in turn, stopping if the ask ends
/// first.
Future<void> cutAll(WidgetTester tester, List<int> places) async {
  for (final place in places) {
    if (state(tester).play.isOver) return;
    await cutAt(tester, place);
  }
}

/// Does what the pointer says, once.
Future<void> cutByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await cutAt(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] cuts at most.
Future<void> cutByPointerAll(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await cutByPointer(tester);
  }
}
