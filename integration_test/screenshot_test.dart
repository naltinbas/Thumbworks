import 'package:flutter/material.dart' hide Card, Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fanwright/game/book.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/solver.dart';
import 'package:fanwright/game/table.dart';
import 'package:fanwright/ui/app.dart';
import 'package:fanwright/ui/game_screen.dart';
import 'package:fanwright/ui/table_painter.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A patience game photographed at the deal is fifty two cards nobody has
// touched. The picture that matters is the hint one: a card rounded in gold
// and the place it is going rounded too, which is the one thing this game does
// that a pack of cards on a table cannot.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// A real deal taken part way down the solver's own line, so the position in
/// the pictures is one a player could be in.
late final Game _partWay;

Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

Future<void> _tapAt(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

TablePainter _painter(WidgetTester tester) => tester
    .widget<CustomPaint>(find
        .byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is TablePainter,
        )
        .first)
    .painter! as TablePainter;

Offset _cardAt(WidgetTester tester, int column, int card) {
  final painter = _painter(tester);
  final metrics = painter.metrics;
  final held = painter.table.column(column);
  final step = metrics.stepFor(held.length);
  final box = Rect.fromLTWH(
    metrics.gap + column * (metrics.cardWidth + metrics.gap),
    metrics.columnsTop + card * step,
    metrics.cardWidth,
    card == held.length - 1 ? metrics.cardHeight : step,
  );
  final origin = tester.getTopLeft(find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is TablePainter,
  ).first);
  return origin + box.center;
}

/// Waits for the solver, which runs on another thread.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (!tester.state<GameScreenState>(find.byType(GameScreen)).thinking) {
      return;
    }
  }
}

Future<void> _open(WidgetTester tester, {Game? at, bool playing = true}) async {
  await tester.pumpWidget(
    FanwrightApp(opening: at, opensPlaying: playing),
  );
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere and may be done only
  // once in a test.
  await binding.convertFlutterSurfaceToImage();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.shouldPropagateDevicePointerEvents = true;

    var game = Game.deal(Book.at(0));
    final line = const Solver().solve(game.table).moves;
    for (final move in line.take(18)) {
      game = game.play(move);
    }
    _partWay = game;
  });

  testWidgets('opens on a title that makes the promise', (tester) async {
    await _open(tester, playing: false);

    expect(find.text('Fanwright'), findsOneWidget);
    expect(find.text('Every deal in here can be won'), findsOneWidget);
    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a deal, a hint, and the move it asked for',
      (tester) async {
    await _open(tester, at: _partWay);
    await _shoot(tester, '02-deal');

    await _tapAt(tester, tester.getCenter(find.text('Hint')));
    await _settle(tester);

    final lit = _painter(tester).lit;
    expect(lit, isNotEmpty, reason: 'the hint should point at something');
    await _shoot(tester, '03-hint');

    // Take it. Tapping what a hint pointed at plays that move rather than the
    // game's own guess, which is the whole point of pointing.
    final from = lit.first;
    if (from.where == Where.column) {
      await _tapAt(tester, _cardAt(tester, from.at, from.card ?? 0));
      await tester.pump(const Duration(milliseconds: 200));
      await _shoot(tester, '04-taken');
    }
  });

  testWidgets('photographs the last card going home', (tester) async {
    // Played, not posed: the deal is taken all the way down the solver's line
    // on the device itself.
    var game = Game.deal(Book.at(0));
    for (final move in const Solver().solve(game.table).moves) {
      game = game.play(move);
    }
    await _open(tester, at: game);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Out'), findsOneWidget);
    await _shoot(tester, '05-out');
  });
}
