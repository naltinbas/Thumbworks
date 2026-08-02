import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/stroke.dart';
import 'package:chalkway/sim/world.dart';
import 'package:chalkway/ui/app.dart';

import 'support/board.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The moments are real ones. The lines are drawn by dragging a finger across
/// the board and the ball is wherever the simulation has actually put it after
/// so many seconds, because there is only one simulation and this is it.
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
    int? level,
    Drawing? opening,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: ChalkwayApp(opensAt: level, opening: opening),
      ),
    );
    await tester.pump();
  }

  /// Runs the ball on for so many seconds of world time.
  Future<void> runFor(WidgetTester tester, double seconds) async {
    for (var i = 0; i < 2000; i++) {
      final world = state(tester).world;
      if (world == null || world.isOver || world.seconds >= seconds) return;
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the levels on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'levels-${phone.key}');
    });

    testWidgets('a line half drawn on ${phone.key}', (tester) async {
      // The finger is still down, so the stroke is drawn in wet chalk — the
      // one thing on this board that is not yet a decision.
      await show(tester, phone.value, level: 3);
      const from = Spot(5.62, 10.88);
      const to = Spot(9.00, 10.60);

      final finger = await tester.startGesture(onScreen(tester, from));
      for (var i = 1; i <= 7; i++) {
        await finger.moveTo(onScreen(tester, from + (to - from) * (i / 11)));
        await tester.pump();
      }
      await capture(tester, 'drawing-${phone.key}');
      await finger.up();
      await tester.pump();
    });

    testWidgets('the ball on its way on ${phone.key}', (tester) async {
      await show(tester, phone.value, level: 5, opening: Levels.at(5).answer);
      await press(tester, 'Let go');
      // Far enough that the trail says where it has been and it has not
      // arrived yet.
      await runFor(tester, 1.5);
      await capture(tester, 'running-${phone.key}');
    });
  }

  testWidgets('a level with spikes in it', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      level: 6,
      opening: Levels.at(6).answer,
    );
    await press(tester, 'Let go');
    await runFor(tester, 1.1);
    await capture(tester, 'spikes');
  });

  testWidgets('the ball in the ring', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      level: 4,
      opening: Levels.at(4).answer,
    );
    await letGo(tester);
    await tester.pump();
    await capture(tester, 'in');
  });

  testWidgets('a line that did not work', (tester) async {
    await show(tester, phones['iphone-14']!, level: 7);
    await drawFrom(tester, const Spot(4.8, 12.2), const Spot(3.6, 13.1));
    // Asserted, because a picture captioned as a miss that quietly became a
    // win is worse than no picture.
    expect(await letGo(tester), isNot(Ending.home));
    await tester.pump();
    await capture(tester, 'missed');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'levels-iphone-14.png',
      'drawing-iphone-14.png',
      'running-iphone-14.png',
      'spikes.png',
      'in.png',
      'missed.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
