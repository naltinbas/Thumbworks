import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emberlane/sim/plan.dart';
import 'package:emberlane/sim/run.dart';
import 'package:emberlane/ui/app.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses. Pictures from an actual emulator and
/// simulator come from CI.
///
/// The positions are real. Each one is a run played by the careful plan and
/// stopped at a moment — six towers up, things walking, a wave part way
/// through — because a posed field is a field no run ever reached and it shows.
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
    Run? at,
    bool playing = true,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: EmberlaneApp(opening: at, opensPlaying: playing),
      ),
    );
    await tester.pump();
  }

  /// The careful plan, stopped part way through a wave with things walking.
  Run partWay({required int wave, int walking = 4}) => Plan.held.play(
        until: (run) =>
            run.wave >= wave && !run.waiting && run.walking.length >= walking,
      );

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

    testWidgets('a wave under way on ${phone.key}', (tester) async {
      await show(tester, phone.value, at: partWay(wave: 8));
      await letItRun(tester, const Duration(milliseconds: 400));
      await capture(tester, 'wave-${phone.key}');
    });
  }

  testWidgets('placing a tower, with every square it could go on lit',
      (tester) async {
    await show(tester, phones['iphone-14']!, at: partWay(wave: 6));
    await tester.tap(find.text('Forge'));
    await tester.pump();
    await letItRun(tester, const Duration(milliseconds: 200));
    await capture(tester, 'placing');
  });

  testWidgets('a tower asked what it can do', (tester) async {
    final run = partWay(wave: 6);
    await show(tester, phones['iphone-14']!, at: run);
    await tapCell(tester, run.built.first.on);
    await letItRun(tester, const Duration(milliseconds: 200));
    expect(find.textContaining('Sell'), findsOneWidget);
    await capture(tester, 'tower');
  });

  testWidgets('the keep falling', (tester) async {
    // Not posed: the careless plan really does lose, and this is the frame it
    // loses on.
    final run = Plan.silly.play(until: (at) => at.keep <= 1);
    await show(tester, phones['iphone-14']!, at: run);
    await letItRun(tester, const Duration(seconds: 30));

    expect(find.text('The keep falls'), findsOneWidget);
    await capture(tester, 'fallen');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    expect(made, contains('title-iphone-14.png'));
    expect(made, contains('wave-iphone-14.png'));
    expect(made, contains('placing.png'));
    expect(made.length, greaterThanOrEqualTo(9));
  });
}
