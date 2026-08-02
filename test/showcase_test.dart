import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinderplot/game/play.dart';
import 'package:cinderplot/game/plots.dart';
import 'package:cinderplot/ui/app.dart';

import 'support/plot.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The boards are real ones, laid out by the real maker, and the squares in
/// them are opened by tapping where those squares are. The hint on show is
/// the hint the reasoner actually gives.
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

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(key: screen, child: CinderplotApp(opensAt: which)),
    );
    await tester.pump();
  }

  /// Plays the board a way along by asking why and doing it, which is the
  /// only way to open squares without knowing where the mines are.
  Future<void> playOn(WidgetTester tester, int turns) async {
    for (var turn = 0; turn < turns; turn++) {
      if (state(tester).play.isOver) return;
      await press(tester, 'Why?');
      if (state(tester).showing == null) return;
      await press(tester, 'Do it');
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the plots on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'plots-${phone.key}');
    });

    testWidgets('a board part way in on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await playOn(tester, 14);
      await tester.pump(const Duration(seconds: 47));
      await capture(tester, 'digging-${phone.key}');
    });

    testWidgets('an answer on show on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await playOn(tester, 20);
      await tester.pump(const Duration(seconds: 96));
      await press(tester, 'Why?');
      expect(state(tester).showing, isNotNull);
      await capture(tester, 'why-${phone.key}');
    });
  }

  testWidgets('a board cleared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tester.pump(const Duration(seconds: 71));
    await playOn(tester, 500);
    expect(state(tester).play.ending, Ending.cleared);
    await capture(tester, 'cleared');
  });

  testWidgets('a board gone up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await playOn(tester, 10);
    await tester.pump(const Duration(seconds: 38));
    // Deliberately: this is the picture of what a mistake looks like, and the
    // only way to make one on purpose is to look.
    await tapSquare(tester, aMine(tester));
    expect(state(tester).play.ending, Ending.blown);
    await capture(tester, 'gone-up');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'plots-iphone-14.png',
      'digging-iphone-14.png',
      'why-iphone-14.png',
      'cleared.png',
      'gone-up.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
    expect(Plots.count, 3);
  });
}
