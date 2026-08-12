import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchmere/ui/app.dart';
import 'package:watchmere/ui/watch_screen.dart';
import 'package:watchmere/ui/watchview.dart';
import 'package:watchmere/watch/meres.dart';

/// Opens the app on a mere, or on the wall when [which] is
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
  await tester.pumpWidget(const WatchmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Meres.at(which).name));
    await tester.pumpAndSettle();
  }
}

WatchScreenState state(WidgetTester tester) =>
    tester.state<WatchScreenState>(find.byType(WatchScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The mere board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Slides a watch one hour by tapping its half.
Future<void> slide(WidgetTester tester, int watch, bool later) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  final bar = metrics.barOf(watch);
  final at = later
      ? Offset(bar.right - bar.height * 0.3, bar.center.dy)
      : Offset(bar.left + bar.height * 0.3, bar.center.dy);
  await tester.tapAt(room.topLeft + at);
  await tester.pumpAndSettle();
}

/// Slides a watch until it starts at [start].
Future<void> slideTo(WidgetTester tester, int watch, int start) async {
  var guard = 0;
  while (state(tester).play.starts[watch] != start && guard++ < 12) {
    await slide(
        tester, watch, state(tester).play.starts[watch] < start);
  }
}

/// Slides by the pointer until the mere lands.
Future<void> dialByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 24) {
    await press(tester, 'Show me');
    final (watch, later) = state(tester).pointing!;
    await slide(tester, watch, later);
  }
}
