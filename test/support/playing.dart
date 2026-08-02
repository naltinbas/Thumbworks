import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/ui/app.dart';
import 'package:chimefall/ui/play_screen.dart';
import 'package:chimefall/ui/stage_painter.dart';

/// The bits every test that watches a tune needs.
///
/// Everything here runs the game silent: the screen takes its time from a
/// plain clock instead of from a player. That is not a stub of the game — the
/// game is the same either way, because everything that judges anything works
/// off a number of seconds and does not care where the number came from. What
/// it avoids is needing a speaker to find out whether a tap was on time.

/// A phone to lay the lanes out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  Tune? tune,
  bool playing = true,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ChimefallApp(
    opensWith: playing ? tune : null,
    silent: true,
  ));
  await tester.pump();
}

PlayScreenState state(WidgetTester tester) =>
    tester.state<PlayScreenState>(find.byType(PlayScreen));

Finder stagePaint() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is StagePainter,
    );

StagePainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(stagePaint().first).painter! as StagePainter;

Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

/// Where a note is drawn right now, measured down the screen.
double heightOf(WidgetTester tester, Note note) {
  final tune = state(tester).session.tune;
  return metricsOf(tester).heightOf(
    note.secondsAt(tune.beatsPerMinute),
    state(tester).session.at,
  );
}

/// Runs the tune on until it is at [seconds], a frame at a time.
Future<void> runTo(WidgetTester tester, double seconds) async {
  const frame = Duration(milliseconds: 8);
  for (var i = 0; i < 20000; i++) {
    if (state(tester).session.at >= seconds) return;
    await tester.pump(frame);
  }
}

/// Taps a lane, on the hit line.
Future<void> tapLane(WidgetTester tester, int lane) async {
  final metrics = metricsOf(tester);
  await tester.tapAt(
    tester.getTopLeft(stagePaint().first) +
        Offset(metrics.middleOf(lane), metrics.line),
  );
  await tester.pump();
}
