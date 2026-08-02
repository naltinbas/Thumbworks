import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockstead/lock/boards.dart';
import 'package:lockstead/lock/marks.dart';
import 'package:lockstead/ui/app.dart';

import 'support/bench.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The guesses in them are real ones. Every row was put in a peg at a time and
/// marked by the lock, and the ones the game chose are the ones it would
/// choose for anybody.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  late Marks gate;

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    gate = Marks.of(Boards.at(0).lock);

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

  var opened = 0;

  Future<void> show(
    WidgetTester tester,
    Size size, {
    int? which,
    Marks? marks,
    int? secret,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: LocksteadApp(
          key: ValueKey(opened++),
          opensAt: which,
          marks: marks,
          secret: secret,
        ),
      ),
    );
    await tester.pump();
  }

  /// Plays a few rows by asking, which is the only way to fill a board in a
  /// test without being told the code.
  Future<void> playOn(WidgetTester tester, int rows) async {
    for (var i = 0; i < rows; i++) {
      if (state(tester).play?.isOver ?? true) return;
      await press(tester, 'Show me');
      await press(tester, 'Try it');
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the rack on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'rack-${phone.key}');
    });

    testWidgets('a lock part way in on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0, marks: gate, secret: 733);
      await playOn(tester, 2);
      // A row half filled, so the empty pegs and the lit slot show.
      await putPeg(tester, 3);
      await putPeg(tester, 5);
      await capture(tester, 'picking-${phone.key}');
    });

    testWidgets('being shown a guess on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0, marks: gate, secret: 733);
      await playOn(tester, 2);
      await press(tester, 'Show me');
      expect(state(tester).saying, isNotNull);
      await capture(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a lock opened', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0, marks: gate,
        secret: 733);
    await pickIt(tester);
    expect(state(tester).play!.isOpen, isTrue);
    await capture(tester, 'open');
  });

  testWidgets('a lock that beat you', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0, marks: gate, secret: 0);
    for (var i = 0; i < 5; i++) {
      await tryCode(tester, [1, 2, 3, 4]);
    }
    expect(state(tester).play!.isLost, isTrue);
    await capture(tester, 'shut');
  });

  testWidgets('the biggest lock there is', (tester) async {
    await show(
      tester,
      phones['iphone-14']!,
      which: 2,
      marks: Marks.of(Boards.at(2).lock),
      secret: 2001,
    );
    await playOn(tester, 3);
    await capture(tester, 'the-vault');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rack-iphone-14.png',
      'picking-iphone-14.png',
      'shown-iphone-14.png',
      'open.png',
      'shut.png',
      'the-vault.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
