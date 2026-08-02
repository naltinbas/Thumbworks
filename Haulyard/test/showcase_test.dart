import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haulyard/ui/app.dart';
import 'package:haulyard/yard/levels.dart';
import 'package:haulyard/yard/yard.dart';

import 'support/yard.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// The positions in them are real ones. Crates are shoved by tapping the
/// squares they are in, and the yard in the picture is wherever those shoves
/// actually left it.
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

  var opened = 0;

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: HaulyardApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  /// Follows what the game says for so many shoves, and stops there.
  Future<void> workOn(WidgetTester tester, int shoves) async {
    for (var turn = 0; turn < shoves; turn++) {
      if (state(tester).yard.isDone) return;
      await press(tester, 'Show me');
      final painter = painterOf(tester);
      final crate = painter.pointAt;
      final way = painter.pointWay;
      if (crate == null || way == null) return;
      await tapSquare(tester, state(tester).yard.ground.beyond(crate, way.back));
      await tapSquare(tester, crate);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the yards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'yards-${phone.key}');
    });

    testWidgets('a yard part way through on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 9);
      await workOn(tester, 3);
      await capture(tester, 'working-${phone.key}');
    });

    testWidgets('being shown what to do on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 11);
      await workOn(tester, 4);
      await press(tester, 'Show me');
      expect(painterOf(tester).pointAt, isNotNull);
      await capture(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a crate that can never come back', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await spoilTheFirstYard(tester);
    expect(state(tester).saying, contains('cannot reach a mark'));
    await capture(tester, 'spoiled');
  });

  testWidgets('a yard finished in the fewest shoves there are', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await workItThrough(tester);
    expect(state(tester).yard.isDone, isTrue);
    expect(state(tester).yard.pushes, Levels.at(4).par);
    await capture(tester, 'done');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yards-iphone-14.png',
      'working-iphone-14.png',
      'shown-iphone-14.png',
      'spoiled.png',
      'done.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
    expect(Way.values, hasLength(4));
  });
}
