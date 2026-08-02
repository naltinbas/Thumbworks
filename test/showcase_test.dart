import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Card, Table;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/game/book.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/solver.dart';
import 'package:fanwright/ui/app.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses. Pictures from an actual emulator and
/// simulator come from CI.
///
/// The positions are real. The half played ones are a real deal taken part way
/// down the solver's own line, which is a position a player could be in rather
/// than a hand somebody arranged.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box. On a table made of ranks and pips that is not a detail: it
    // is every card in every picture.
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

  Future<void> show(
    WidgetTester tester,
    Size size, {
    Game? at,
    bool playing = true,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: FanwrightApp(opening: at, opensPlaying: playing),
      ),
    );
    await tester.pump();
  }

  /// A real deal, taken [moves] moves down the solver's own line.
  Game partWay(int number, int moves) {
    var game = Game.deal(number);
    final line = const Solver().solve(game.table).moves;
    for (final move in line.take(moves)) {
      game = game.play(move);
    }
    return game;
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the title on ${phone.key}', (tester) async {
      await show(tester, phone.value, playing: false);
      await capture(tester, 'title-${phone.key}');
    });

    testWidgets('a deal on ${phone.key}', (tester) async {
      await show(tester, phone.value, at: Game.deal(Book.at(0)));
      await capture(tester, 'deal-${phone.key}');
    });
  }

  testWidgets('part way through', (tester) async {
    await show(tester, phones['iphone-14']!, at: partWay(Book.at(0), 24));
    await capture(tester, 'playing');
  });

  testWidgets('the hint, pointing at a card and where it goes',
      (tester) async {
    await show(tester, phones['iphone-14']!, at: partWay(Book.at(0), 18));
    await tester.tap(find.text('Hint'));
    await settle(tester);
    expect(painterOf(tester).lit, isNotEmpty);
    await capture(tester, 'hint');
  });

  testWidgets('the last card home', (tester) async {
    // Played rather than posed: the deal is taken all the way down the line
    // and the picture is of the game finishing.
    await show(tester, phones['iphone-14']!, at: partWay(Book.at(0), 9999));
    expect(table(tester).isWon, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'won');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    expect(made, contains('title-iphone-14.png'));
    expect(made, contains('deal-iphone-14.png'));
    expect(made, contains('hint.png'));
    expect(made.length, greaterThanOrEqualTo(9));
  });
}
