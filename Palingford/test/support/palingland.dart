import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palingford/paling/levels.dart';
import 'package:palingford/ui/app.dart';
import 'package:palingford/ui/paling_screen.dart';
import 'package:palingford/ui/palingview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the fence line when [which] is null.
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
  await tester.pumpWidget(const PalingfordApp());
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

PalingScreenState state(WidgetTester tester) =>
    tester.state<PalingScreenState>(find.byType(PalingScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

Metrics _metrics(WidgetTester tester) {
  final where = board(tester);
  return Metrics(state(tester).play, where.size);
}

/// Where a standing paling is, which is where a thumb goes to lift it.
Offset palingAt(WidgetTester tester, int place) {
  final m = _metrics(tester);
  return board(tester).topLeft + Offset(m.middleOf(place), m.ground - 4);
}

/// Where a gap is, which is where a thumb goes to put a paling back.
Offset gapAt(WidgetTester tester, int gap) {
  final m = _metrics(tester);
  return board(tester).topLeft + Offset(m.gapLine(gap), m.ground - 4);
}

/// A point in the air over the fence, which is no paling at all.
Offset skyAt(WidgetTester tester) =>
    board(tester).topLeft + Offset(board(tester).width / 2, 2);

Future<void> lift(WidgetTester tester, int place) async {
  await tester.tapAt(palingAt(tester, place));
  await tester.pumpAndSettle();
}

Future<void> slideTo(WidgetTester tester, int gap) async {
  await tester.tapAt(gapAt(tester, gap));
  await tester.pumpAndSettle();
}

/// Lifts a paling and slides it in, which is one move and two taps.
Future<void> move(WidgetTester tester, int place, int gap) async {
  await lift(tester, place);
  await slideTo(tester, gap);
}

/// Does what the pointer says, once.
Future<void> moveByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).play.next!;
  await move(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] moves at most.
Future<void> fenceByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await moveByPointer(tester);
  }
}
