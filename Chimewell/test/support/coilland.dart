import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chimewell/coil/levels.dart';
import 'package:chimewell/ui/app.dart';
import 'package:chimewell/ui/coil_screen.dart';
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
  await tester.pumpWidget(const ChimewellApp());
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

CoilScreenState state(WidgetTester tester) =>
    tester.state<CoilScreenState>(find.byType(CoilScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'fifths' or 'octaves', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Turns the dials from where they stand to [fifths] and [octaves], a
/// step a tap, the fifths first.
Future<void> setDials(WidgetTester tester, int fifths, int octaves) async {
  while (state(tester).play.fifths != fifths && !state(tester).play.isOver) {
    await turn(tester, 'fifths', (fifths - state(tester).play.fifths).sign);
  }
  while (state(tester).play.octaves != octaves && !state(tester).play.isOver) {
    await turn(tester, 'octaves', (octaves - state(tester).play.octaves).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which == 0 ? 'fifths' : 'octaves', by);
}

/// Follows the pointer until the note lands, [most] steps at most.
Future<void> soundByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
