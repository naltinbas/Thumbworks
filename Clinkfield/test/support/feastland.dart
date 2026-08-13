import 'package:clinkfield/clink/feasts.dart';
import 'package:clinkfield/ui/app.dart';
import 'package:clinkfield/ui/clink_screen.dart';
import 'package:clinkfield/ui/clinkview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a feast, or on the field when [which] is
/// null.
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
  await tester.pumpWidget(const ClinkfieldApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Feasts.at(which).name));
    await tester.pumpAndSettle();
  }
}

ClinkScreenState state(WidgetTester tester) =>
    tester.state<ClinkScreenState>(find.byType(ClinkScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The field board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a pair's wire through the painter's metrics.
Future<void> tapWire(WidgetTester tester, int pair) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.midOf(pair));
  await tester.pumpAndSettle();
}

/// Clinks by the pointer until the feast lands.
Future<void> feastByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final pair = state(tester).pointing!;
    await tapWire(tester, pair);
  }
}
