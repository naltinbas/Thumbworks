import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thornguard/game/board.dart';
import 'package:thornguard/game/game.dart';
import 'package:thornguard/game/search.dart';
import 'package:thornguard/opponent.dart';
import 'package:thornguard/ui/app.dart';
import 'package:thornguard/ui/board_painter.dart';
import 'package:thornguard/ui/board_view.dart';
import 'package:thornguard/ui/game_screen.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A board game photographed at rest is a grid of dots and says nothing about
// what playing it is like. So the picture that matters is taken with a man
// picked up and every square he can reach lit, which is the only moment in
// this game where the screen is doing something the board could not.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// The side the pictures are taken from.
const _playing = Side.guards;

/// How far into the game the pictures are taken, in plies.
const _plies = 14;

late final Game _position;

/// Sends a pointer event the way the device would rather than the way a test
/// does.
///
/// The two arrive at the game identically. The difference is that the live
/// binding paints a bright crosshair over wherever a test-sourced pointer last
/// was, and here that is the middle of the board in every picture.
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

Offset _squareAt(WidgetTester tester, Square at) {
  final painted = tester
      .widgetList<CustomPaint>(find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(CustomPaint),
      ))
      .map((paint) => paint.painter)
      .whereType<BoardPainter>()
      .first;
  return tester.getTopLeft(find.byType(BoardView)) +
      painted.metrics.squareAt(at).center;
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

/// Opens the game.
///
/// [at] is a position to start from; without it the app opens on its title,
/// which is where a player arrives.
Future<void> _open(WidgetTester tester, {Game? at}) async {
  await tester.pumpWidget(
    at == null
        ? const ThornguardApp(playing: _playing, strength: Strength.sharp)
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThornguardApp.theme,
            home: GameScreen(
              playing: _playing,
              strength: Strength.sharp,
              onLeave: () {},
              opening: at,
            ),
          ),
  );
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere, it may be done only
  // once in a test, and the binding puts it back afterwards.
  await binding.convertFlutterSurfaceToImage();
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Device pointers are dropped by a live test unless this is set.
    binding.shouldPropagateDevicePointerEvents = true;

    // A real game, played out here rather than posed: the search takes both
    // sides from the opening, so every man in the pictures is somewhere a game
    // actually put him.
    var game = Game.fresh();
    while (!game.isOver &&
        (game.played < _plies || game.board.turn != _playing)) {
      final thought = const Search(depth: 4).think(game.board);
      if (thought.move == null) break;
      game = game.play(thought.move!);
    }
    _position = game;
  });

  testWidgets('opens on a title with both choices on it', (tester) async {
    await _open(tester);

    expect(find.text('Thornguard'), findsOneWidget);
    expect(find.textContaining('Guards'), findsOneWidget);
    expect(find.textContaining('Sharp'), findsOneWidget);

    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a man picked up, with his squares lit',
      (tester) async {
    await _open(tester, at: _position);
    expect(find.byType(BoardView), findsOneWidget);
    await _shoot(tester, '02-position');

    // The man with the most to say, because the picture is about the dots.
    var best = _position.board.moves.first.from;
    var most = 0;
    for (final from in _position.board.occupied) {
      final count =
          _position.board.moves.where((move) => move.from == from).length;
      if (count > most) {
        most = count;
        best = from;
      }
    }

    await _tapAt(tester, _squareAt(tester, best));
    final view = tester.widget<BoardView>(find.byType(BoardView));
    expect(view.picked, best);
    expect(view.destinations, isNotEmpty);
    await _shoot(tester, '03-picked');

    // And the move played, so the last pair of squares is marked and the
    // opponent is thinking about its reply.
    await _tapAt(tester, _squareAt(tester, view.destinations.first));
    await _shoot(tester, '04-moved');
  });

  testWidgets('photographs the opponent finding the king', (tester) async {
    // Three raiders round the king and a fourth a move away. Nothing here is
    // played by the test: it hands the position over and waits for the
    // opponent to find it, on the device, on its own thread.
    final near = Game.at(Board.of(const [
      '       ',
      ' R     ',
      'RK     ',
      ' R  G  ',
      '       ',
      '  R    ',
      '   R   ',
    ], turn: Side.raiders));
    await _open(tester, at: near);

    for (var i = 0; i < 400; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (find.text('The king is taken').evaluate().isNotEmpty) break;
    }

    expect(find.text('The king is taken'), findsOneWidget);
    await _shoot(tester, '05-taken');
  });
}
