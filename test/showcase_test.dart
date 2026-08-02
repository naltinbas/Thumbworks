import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/play.dart';
import 'package:hazardwell/game/rules.dart';
import 'package:hazardwell/ui/app.dart';

import 'support/table.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The positions are real ones and so are the odds beside them — the same
/// table the house plays by, worked out in this test like anywhere else.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  late Odds odds;

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    odds = Odds.reckon();

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture — and this game is mostly numbers.
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

  var opened = 0;

  Future<void> show(
    WidgetTester tester,
    Size size, {
    bool atTable = true,
    Play? from,
    List<int> dice = const [5, 3],
    bool showOdds = true,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: HazardwellApp(
          key: ValueKey(opened++),
          odds: odds,
          opensAtTable: atTable,
          opensWith: from,
          dice: Loaded(dice),
          showOdds: showOdds,
        ),
      ),
    );
    await tester.pump();
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the way in on ${phone.key}', (tester) async {
      await show(tester, phone.value, atTable: false);
      await capture(tester, 'way-in-${phone.key}');
    });

    testWidgets('a turn under way on ${phone.key}', (tester) async {
      await show(
        tester,
        phone.value,
        from: const Play(yours: 43, theirs: 51, turn: 0, toMove: Who.you),
        dice: const [6, 4],
      );
      await press(tester, 'Two dice');
      await press(tester, 'One die');
      await capture(tester, 'turn-${phone.key}');
    });

    testWidgets('a pair, which pays double, on ${phone.key}', (tester) async {
      await show(
        tester,
        phone.value,
        from: const Play(yours: 62, theirs: 58, turn: 7, toMove: Who.you),
        dice: const [5, 5],
      );
      await press(tester, 'Two dice');
      expect(state(tester).play.turn, 7 + 20);
      await capture(tester, 'pair-${phone.key}');
    });
  }

  testWidgets('two ones, which take everything', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      from: const Play(yours: 71, theirs: 64, turn: 18, toMove: Who.you),
      dice: const [1],
    );
    await press(tester, 'Two dice');
    expect(state(tester).play.yours, 0);
    await capture(tester, 'wiped');
  });

  testWidgets('the end of a game, and what it cost', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      from: const Play(yours: 88, theirs: 74, turn: 0, toMove: Who.you),
      dice: const [6, 6, 4],
    );
    // Rolling on with the game already won is the classic way to give one
    // away, so the review has something to say.
    await press(tester, 'Two dice');
    while (!state(tester).play.isOver) {
      final play = state(tester).play;
      if (state(tester).theirs) {
        await tester.pump(const Duration(milliseconds: 900));
        continue;
      }
      final best = odds.bestAt(play.mine, play.others, play.turn);
      await press(tester, switch (best) {
        Move.bank => 'Bank ${play.turn}',
        Move.one => 'One die',
        Move.two => 'Two dice',
      });
    }
    await capture(tester, 'the-end');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'way-in-iphone-14.png',
      'turn-iphone-14.png',
      'pair-iphone-14.png',
      'wiped.png',
      'the-end.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
