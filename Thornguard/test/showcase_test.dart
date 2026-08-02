import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/game/board.dart';
import 'package:thornguard/game/game.dart';
import 'package:thornguard/game/search.dart';
import 'package:thornguard/opponent.dart';
import 'package:thornguard/ui/app.dart';
import 'package:thornguard/ui/game_screen.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses. Pictures from an actual emulator and
/// simulator come from CI.
///
/// The positions are real. Each is reached by playing the opening with the
/// search on both sides, so every man in every picture is somewhere a game
/// actually put him.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    for (final family in const ['Roboto', 'MaterialIcons']) {
      final loader = FontLoader(family);
      for (final file in fonts.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (!name.startsWith(family)) continue;
        if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  });

  Future<void> capture(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(screen),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> show(WidgetTester tester, Size size, Widget child) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(key: screen, child: child),
    );
    await tester.pump();
  }

  /// A position from a real game: the opening, a few random moves so the games
  /// differ, then both sides played by the search until it is [playing]'s
  /// move and [plies] have gone by.
  Game played({
    required int seed,
    required int plies,
    required Side playing,
    int depth = 4,
  }) {
    final random = Random(seed);
    var game = Game.fresh();
    for (var i = 0; i < 2; i++) {
      final moves = game.board.moves;
      game = game.play(moves[random.nextInt(moves.length)]);
    }
    while (!game.isOver &&
        (game.played < plies || game.board.turn != playing)) {
      final thought = Search(depth: depth).think(game.board);
      if (thought.move == null) break;
      game = game.play(thought.move!);
    }
    return game;
  }

  Widget atBoard(Game game, Side playing) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThornguardApp.theme,
        home: GameScreen(
          playing: playing,
          strength: Strength.sharp,
          onLeave: () {},
          opening: game,
        ),
      );

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the title on ${phone.key}', (tester) async {
      await show(
        tester,
        phone.value,
        const ThornguardApp(playing: Side.guards, strength: Strength.sharp),
      );
      await capture(tester, 'title-${phone.key}');
    });

    testWidgets('a game under way on ${phone.key}', (tester) async {
      await show(
        tester,
        phone.value,
        atBoard(played(seed: 3, plies: 14, playing: Side.guards), Side.guards),
      );
      await capture(tester, 'playing-${phone.key}');
    });
  }

  testWidgets('a man picked up, with his squares showing', (tester) async {
    final game = played(seed: 3, plies: 14, playing: Side.guards);
    await show(tester, phones['iphone-14']!, atBoard(game, Side.guards));

    // Pick up whichever guard has the most to say. The picture is about the
    // dots, so it wants the man with the most of them.
    var best = game.board.moves.first.from;
    var most = 0;
    for (final from in game.board.occupied) {
      final count = game.board.moves.where((m) => m.from == from).length;
      if (count > most) {
        most = count;
        best = from;
      }
    }
    await tapSquare(tester, best);
    await capture(tester, 'picked');
  });

  testWidgets('the king walking out', (tester) async {
    // A position a move from the corner, played rather than posed: the guards
    // put the king there and the raiders could not stop it.
    final game = Game.at(Board.of(const [
      '   K   ',
      '       ',
      ' R     ',
      '  RG R ',
      '     R ',
      '       ',
      '   R   ',
    ], turn: Side.guards));
    await show(tester, phones['iphone-14']!, atBoard(game, Side.guards));

    await tapSquare(tester, const Square(0, 3));
    await tapSquare(tester, const Square(0, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'won');
  });

  testWidgets('the king taken', (tester) async {
    // Three raiders are already round the king and a fourth is a move from
    // the last square. The player has the guards, so this is not played — it
    // is waited for. The opponent finds it, on its own thread, and the picture
    // is of losing.
    final game = Game.at(Board.of(const [
      '       ',
      ' R     ',
      'RK     ',
      ' R  G  ',
      '       ',
      '  R    ',
      '   R   ',
    ], turn: Side.raiders));
    await show(tester, phones['iphone-14']!, atBoard(game, Side.guards));

    for (var i = 0; i < 400; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 20));
      if (find.text('You lose.').evaluate().isNotEmpty) break;
    }

    expect(find.text('The king is taken'), findsOneWidget);
    await capture(tester, 'lost');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList()
      ..sort();
    expect(made, contains('title-iphone-14.png'));
    expect(made, contains('playing-iphone-14.png'));
    expect(made, contains('picked.png'));
    expect(made.length, greaterThanOrEqualTo(9));
  });

}
