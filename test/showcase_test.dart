import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/tune/tunes.dart';
import 'package:chimefall/ui/app.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The moments are real ones. The tune is run to a chosen second and the notes
/// on screen are the notes that are actually due then, because they come out
/// of the same list the sound does.
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

  Future<void> show(WidgetTester tester, Size size, {Tune? tune}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: ChimefallApp(opensWith: tune, silent: true),
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
    testWidgets('the tunes on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'tunes-${phone.key}');
    });

    testWidgets('a tune under way on ${phone.key}', (tester) async {
      await show(tester, phone.value, tune: Tunes.third);
      // Far enough in that the screen is full of what is coming.
      await runTo(tester, 6.4);
      await capture(tester, 'falling-${phone.key}');
    });
  }

  testWidgets('the moment a note lands', (tester) async {
    await show(tester, phones['iphone-14']!, tune: Tunes.second);
    final note = Tunes.second.inOrder[14];
    await runTo(tester, note.secondsAt(Tunes.second.beatsPerMinute));
    await tapLane(tester, note.lane);
    await capture(tester, 'perfect');
  });

  testWidgets('the end of a tune, played well', (tester) async {
    await show(tester, phones['iphone-14']!, tune: Tunes.first);
    for (final note in Tunes.first.inOrder) {
      await runTo(tester, note.secondsAt(Tunes.first.beatsPerMinute));
      // Most of them dead on, one dropped, so the card has something to say.
      if (note.at != Tunes.first.inOrder[3].at) {
        await tapLane(tester, note.lane);
      }
    }
    await runTo(tester, Tunes.first.seconds + 0.1);
    await capture(tester, 'done');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    expect(made, contains('tunes-iphone-14.png'));
    expect(made, contains('falling-iphone-14.png'));
    expect(made, contains('perfect.png'));
    expect(made.length, greaterThanOrEqualTo(8));
  });
}
