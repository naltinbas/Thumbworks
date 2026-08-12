import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkfen/ink/lines.dart';
import 'package:inkfen/ui/app.dart';
import 'package:inkfen/ui/ink_screen.dart';
import 'package:inkfen/ui/inkview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a line, or on the fen when [which] is null.
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
  await tester.pumpWidget(const InkfenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Lines.at(which).name));
    await tester.pumpAndSettle();
  }
}

InkScreenState state(WidgetTester tester) =>
    tester.state<InkScreenState>(find.byType(InkScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The fen board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a string through the painter's metrics.
Future<void> tapString(WidgetTester tester, int string) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.midOf(string));
  await tester.pumpAndSettle();
}

/// Dips a string until it wears [ink].
Future<void> dipTo(WidgetTester tester, int string, int ink) async {
  var guard = 0;
  while (state(tester).play.inks[string] != ink && guard++ < 4) {
    await tapString(tester, string);
  }
}

/// Dips by the pointer until the line lands.
Future<void> inkByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final string = state(tester).pointing!;
    await tapString(tester, string);
  }
}
