import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultline/best.dart';
import 'package:vaultline/sim/ground.dart';
import 'package:vaultline/sim/journey.dart';
import 'package:vaultline/ui/app.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses. Pictures from an actual emulator and
/// simulator come from CI.
///
/// The runs in them are real ones, played by the stored proofs — the same
/// thing the tests use and the same thing running behind the title. Nothing
/// here is posed.
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

  Future<void> show(
    WidgetTester tester,
    Size size, {
    Journey? at,
    bool running = true,
    Map<String, Object> saved = const {},
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(Map<String, Object>.from(saved));
    final best = Best(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: VaultlineApp(best: best, opensRunning: running, opening: at),
      ),
    );
    await tester.pump();
  }

  /// A real run, played by the stored proofs up to a point.
  ///
  /// The same trick the tests use: every piece was proved on its own, and a
  /// piece laid at tile t has its proof's step s at the run's step s + 16t.
  /// So the runner in these pictures is being played by the proofs, which is
  /// the only kind of run this game promises exists.
  Journey playedTo(int tiles, {int seed = 3}) {
    var journey = Journey.begin(seed: seed);
    final held = <int>{};
    var known = 0;
    while (!journey.isOver && journey.run.x < tiles) {
      for (; known < journey.laid.length; known++) {
        held.addAll(journey.laid[known].holdsInRun);
      }
      journey = journey.step(holding: held.contains(journey.run.steps));
    }
    return journey;
  }

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
        running: false,
        saved: const {'best.tiles': 418},
      );
      await letItRun(tester, const Duration(milliseconds: 900));
      await capture(tester, 'title-${phone.key}');
    });

    testWidgets('a run under way on ${phone.key}', (tester) async {
      await show(
        tester,
        phone.value,
        at: playedTo(180),
        saved: const {'best.tiles': 418},
      );
      await capture(tester, 'running-${phone.key}');
    });
  }

  testWidgets('mid jump, over a gap', (tester) async {
    // Wound forward to a moment with the runner off the ground, still played
    // by the proofs — stepping without them runs it straight into a wall,
    // which is a picture of the wrong thing.
    var journey = Journey.begin(seed: 3);
    final held = <int>{};
    var known = 0;
    var guard = 0;
    var going = false;
    while (!journey.isOver && guard++ < 12000) {
      for (; known < journey.laid.length; known++) {
        held.addAll(journey.laid[known].holdsInRun);
      }
      journey = journey.step(holding: held.contains(journey.run.steps));
      // Past the flat opening, and in the air.
      going = journey.run.x > 40 && !journey.run.onGround;
      if (going) break;
    }
    expect(going, isTrue, reason: 'never left the ground');

    await show(tester, phones['iphone-14']!, at: journey);
    await capture(tester, 'jumping');
  });

  testWidgets('the run ending', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      at: Journey.on(Ground.of('${'.' * 8}${'_' * 6}${'.' * 40}')),
      saved: const {'best.tiles': 418},
    );
    await letItRun(tester, const Duration(seconds: 3));
    await settle(tester);

    expect(find.text('Down the gap'), findsOneWidget);
    await capture(tester, 'over');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    expect(made, contains('title-iphone-14.png'));
    expect(made, contains('running-iphone-14.png'));
    expect(made, contains('jumping.png'));
    expect(made.length, greaterThanOrEqualTo(8));
  });
}
