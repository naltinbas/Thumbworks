import 'package:almsford/alms/levels.dart';
import 'package:almsford/ui/almsview.dart';
import 'package:almsford/ui/alms_screen.dart';
import 'package:almsford/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  await tester.pumpWidget(const AlmsfordApp());
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

AlmsScreenState state(WidgetTester tester) =>
    tester.state<AlmsScreenState>(find.byType(AlmsScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a bin stands on the screen, which is where a thumb goes.
Offset binAt(WidgetTester tester, int bin) {
  final at = board(tester);
  final m = Metrics(at.size);
  return at.topLeft + Offset(m.pad + m.wide * (bin + 0.5), m.floor - 6);
}

/// Taps a bin, which lifts a measure out of it or puts one in.
Future<void> tapBin(WidgetTester tester, int bin) async {
  await tester.tapAt(binAt(tester, bin));
  await tester.pumpAndSettle();
}

/// Makes one share, from a bin to a bin.
Future<void> share(WidgetTester tester, int from, int to) async {
  await tapBin(tester, from);
  await tapBin(tester, to);
}

/// Does what the pointer says, once, which takes a lift and a drop.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (from, to) = state(tester).pointing!;
  await share(tester, from, to);
}

/// Follows the pointer until the bins stand as asked, [most] shares at
/// most.
Future<void> shareByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
