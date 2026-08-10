import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chasegarth/forme/chases.dart';
import 'package:chasegarth/ui/app.dart';

import 'support/forme.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every slide in them was made by tapping a letter, so nothing in the
/// pictures is a bench the game could not reach.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    await useRealFonts();
  });

  Future<void> shoot(WidgetTester tester, String name) async {
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
        child: ChasegarthApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the formes on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'formes-${phone.key}');
    });

    testWidgets('a forme part slid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var step = 0; step < 12; step++) {
        await slide(tester, state(tester).play.next!);
      }
      await press(tester, 'Show me');
      await shoot(tester, 'sliding-${phone.key}');
    });

    testWidgets('one locked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await lockItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'locked-${phone.key}');
    });
  }

  testWidgets('being told why the dropped forme is stuck', (tester) async {
    final dropped = Formes.all.indexWhere((forme) => forme.dropped);
    await show(tester, phones['iphone-14']!, which: dropped);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the moment after the pair is swapped back', (tester) async {
    final dropped = Formes.all.indexWhere((forme) => forme.dropped);
    await show(tester, phones['iphone-14']!, which: dropped);
    await press(tester, 'Swap them');
    expect(state(tester).play.canBeLocked, isTrue);
    await shoot(tester, 'mended');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'formes-iphone-14.png',
      'sliding-iphone-14.png',
      'locked-iphone-14.png',
      'why.png',
      'mended.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
