import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beatstow/beat/levels.dart';
import 'package:beatstow/ui/app.dart';
import 'package:beatstow/ui/beat_screen.dart';
import 'package:beatstow/ui/beatview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the ring when [which] is null.
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
  await tester.pumpWidget(const BeatstowApp());
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

BeatScreenState state(WidgetTester tester) =>
    tester.state<BeatScreenState>(find.byType(BeatScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a beat's tile is drawn, which is where a thumb goes.
Offset beatAt(WidgetTester tester, int beat) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).handAt(beat).center;
}

/// A point on the chart above the beats, which is no tile at all.
Offset skyAt(WidgetTester tester) {
  final where = board(tester);
  return where.topLeft + Offset(where.width / 2, 12);
}

/// Taps a beat, which lays the throw in hand or lifts the one there.
Future<void> tapBeat(WidgetTester tester, int beat) async {
  await tester.tapAt(beatAt(tester, beat));
  await tester.pumpAndSettle();
}

/// Takes a throw of the given height off the rack.
Future<void> takeThrow(WidgetTester tester, int height) async {
  await tester.tap(find.byKey(Key('rack-$height')));
  await tester.pumpAndSettle();
}

/// Picks a throw up or puts it down again, whichever the rack allows.
/// Once the last throw of a height is in the hand its rack chip is gone,
/// so the tap has to go to the hand instead.
Future<void> jiggle(WidgetTester tester, int height) async {
  final onRack = find.byKey(Key('rack-$height'));
  await tester.tap(onRack.evaluate().isEmpty
      ? find.byKey(const Key('in-hand'))
      : onRack);
  await tester.pumpAndSettle();
}

/// Takes a throw and lays it on a beat.
Future<void> lay(WidgetTester tester, int height, int beat) async {
  await takeThrow(tester, height);
  await tapBeat(tester, beat);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).play.next!;
  if (aim.$1 == null) {
    await tapBeat(tester, aim.$2);
  } else {
    await takeThrow(tester, aim.$1!);
  }
}

/// Follows the pointer until the ring juggles, [most] taps at most.
Future<void> juggleByPointer(WidgetTester tester, {int most = 16}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
