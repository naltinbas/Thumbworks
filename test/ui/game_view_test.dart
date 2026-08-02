import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_view.dart';
import 'package:slingwell/ui/world_painter.dart';

/// Put the view on a phone-shaped screen and let the ticker take its first
/// tick, which is always worth nothing: a ticker counts from when it started,
/// so the first frame it sees is zero seconds after it started.
///
/// Nothing here waits for the tree to settle, and nothing can: the view asks
/// for a frame forever, which is what a game does.
Future<void> _start(WidgetTester tester, GameLoop loop) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: GameView(loop: loop),
    ),
  );
  await tester.pump();
}

WorldPainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<WorldPainter>()
    .single;

void main() {
  testWidgets('the loop runs a step for each step of frame time', (
    tester,
  ) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    expect(loop.world.steps, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(loop.world.steps, 12);

    await tester.pump(const Duration(milliseconds: 100));
    expect(loop.world.steps, 24);
  });

  testWidgets('the loop carries the leftover of a frame into the next', (
    tester,
  ) async {
    // Ten frames of ten milliseconds is a step and a fifth each, and a tenth
    // of a second in total. Twelve steps, not ten.
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(loop.world.steps, 12);
  });

  testWidgets('a slow frame does not run the simulation faster', (
    tester,
  ) async {
    // The same second of frames, drawn at sixty and at a hundred and twenty,
    // has to be the same second of world.
    final fast = GameLoop(seed: 3);
    final slow = GameLoop(seed: 3);
    await _start(tester, fast);
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(microseconds: 8333));
    }
    await tester.pumpWidget(const SizedBox());

    await _start(tester, slow);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(microseconds: 16667));
    }
    expect(slow.world.steps, closeTo(fast.world.steps, 1));
  });

  testWidgets('a tap anywhere on the glass reaches the simulation once', (
    tester,
  ) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    await tester.pump(const Duration(milliseconds: 100));
    expect(loop.world.isHeld, isTrue);

    // A corner, because the whole screen is the button.
    await tester.tapAt(const Offset(24, 60));
    await tester.pump(const Duration(milliseconds: 100));

    expect(loop.world.isHeld, isFalse);
    expect(loop.replay.taps, hasLength(1));

    await tester.pump(const Duration(milliseconds: 300));
    expect(loop.replay.taps, hasLength(1), reason: 'one tap, one release');
  });

  testWidgets('two taps are two releases and not one', (tester) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 16));

    for (var i = 0; i < 200 && !loop.world.isHeld; i++) {
      await tester.pump(const Duration(milliseconds: 8));
    }
    expect(loop.world.isHeld, isTrue, reason: 'expected to catch a well');
    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 16));
    expect(loop.replay.taps, hasLength(2));
  });

  testWidgets('the painter is handed a repaint when the world has moved', (
    tester,
  ) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    final before = _painter(tester);

    await tester.pump(const Duration(milliseconds: 100));
    final after = _painter(tester);

    expect(identical(after, before), isFalse);
    expect(after.shouldRepaint(before), isTrue);
    expect(after.world.steps, greaterThan(before.world.steps));
  });

  testWidgets('the painter is left alone when no step has run', (
    tester,
  ) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    final before = _painter(tester);

    // Shorter than a step, so there is nothing to draw again.
    await tester.pump(const Duration(microseconds: 200));
    expect(_painter(tester).shouldRepaint(before), isFalse);
  });

  testWidgets('the view keeps drawing the run it is given after a restart', (
    tester,
  ) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    await tester.pump(const Duration(milliseconds: 200));
    expect(loop.world.steps, greaterThan(0));

    loop.restart(seed: 9);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_painter(tester).world.seed, 9);
    expect(loop.world.steps, 12);
  });

  testWidgets('the ticker stops when the view goes away', (tester) async {
    final loop = GameLoop(seed: 3);
    await _start(tester, loop);
    await tester.pump(const Duration(milliseconds: 100));
    final steps = loop.world.steps;

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    expect(loop.world.steps, steps);
  });
}
