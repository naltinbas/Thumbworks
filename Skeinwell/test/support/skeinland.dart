import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeinwell/skein/levels.dart';
import 'package:skeinwell/skein/rules.dart';
import 'package:skeinwell/ui/app.dart';
import 'package:skeinwell/ui/skein_screen.dart';
import 'package:skeinwell/ui/skeinview.dart';

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
  await tester.pumpWidget(const SkeinwellApp());
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

SkeinScreenState state(WidgetTester tester) =>
    tester.state<SkeinScreenState>(find.byType(SkeinScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a lane's middle falls on the screen, which is where a thumb
/// goes to lay it or lift it.
Offset laneAt(WidgetTester tester, int lane) {
  final at = board(tester);
  return at.topLeft + Metrics(at.size).lane[lane];
}

/// Taps a lane, which lays it or lifts it.
Future<void> tapLane(WidgetTester tester, int lane) async {
  await tester.tapAt(laneAt(tester, lane));
  await tester.pumpAndSettle();
}

/// Lays and lifts lanes until the village is [want], laying first so
/// that no lift ever cuts a green off.
Future<void> setVillage(WidgetTester tester, List<int> want,
    {int most = 20}) async {
  final aim = Rules.laid(want);
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver || was.village == aim) return;
    var lane = -1;
    for (var i = 0; i < Rules.howManyLanes; i++) {
      if (Rules.has(aim, i) && !was.has(i)) {
        lane = i;
        break;
      }
    }
    if (lane < 0) {
      for (var i = 0; i < Rules.howManyLanes; i++) {
        if (!Rules.has(aim, i) && was.has(i)) {
          lane = i;
          break;
        }
      }
    }
    if (lane < 0) return;
    await tapLane(tester, lane);
    // A tap that changes nothing means the village cannot get there.
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (lane, _) = state(tester).pointing!;
  await tapLane(tester, lane);
}

/// Follows the pointer until the village lands, [most] taps at most.
Future<void> layByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
