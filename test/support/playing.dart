import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultline/best.dart';
import 'package:vaultline/sim/journey.dart';
import 'package:vaultline/ui/app.dart';
import 'package:vaultline/ui/run_screen.dart';
import 'package:vaultline/ui/world_painter.dart';

/// The bits every test that watches a run needs.

/// A phone to lay the game out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  Journey? at,
  bool running = true,
  Map<String, Object> saved = const {},
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(Map<String, Object>.from(saved));
  final best = Best(await SharedPreferences.getInstance());

  await tester.pumpWidget(VaultlineApp(
    best: best,
    opensRunning: running,
    opening: at,
  ));
  await tester.pump();
}

RunScreenState screenState(WidgetTester tester) =>
    tester.state<RunScreenState>(find.byType(RunScreen));

Journey journey(WidgetTester tester) => screenState(tester).journey;

Finder worldPaint() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is WorldPainter,
    );

WorldPainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(worldPaint().first).painter! as WorldPainter;

Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

/// How far the runner behind the title has got.
double shownAt(WidgetTester tester) => painterOf(tester).journey.run.x;

/// Lets the clock run for a while, a frame at a time.
Future<void> letItRun(WidgetTester tester, Duration how) async {
  const frame = Duration(milliseconds: 16);
  for (var gone = Duration.zero; gone < how; gone += frame) {
    await tester.pump(frame);
  }
}

/// Lets whatever was written to disk come back.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 20));
  }
}
