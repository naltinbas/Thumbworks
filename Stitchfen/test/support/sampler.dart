import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitchfen/thread/rows.dart';
import 'package:stitchfen/ui/app.dart';
import 'package:stitchfen/ui/thread_screen.dart';
import 'package:stitchfen/ui/threadview.dart';

/// Opens the app on a row, or on the fen when [which] is null.
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
  await tester.pumpWidget(const StitchfenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Rows.at(which).name));
    await tester.pumpAndSettle();
  }
}

ThreadScreenState state(WidgetTester tester) =>
    tester.state<ThreadScreenState>(find.byType(ThreadScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The sampler board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a stitch through the same metrics the painter draws by.
Future<void> tapStitch(WidgetTester tester, int stitch) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.stitchAt(stitch));
  await tester.pumpAndSettle();
}

/// Flips a stitch until it wears the wanted thread.
Future<void> threadTo(
    WidgetTester tester, int stitch, String thread) async {
  var guard = 0;
  while (
      state(tester).play.threads[stitch] != thread && guard++ < 2) {
    await tapStitch(tester, stitch);
  }
}

/// Threads a whole row to a target.
Future<void> threadAll(WidgetTester tester, String target) async {
  for (var at = 0; at < target.length; at++) {
    await threadTo(tester, at, target[at]);
  }
}
