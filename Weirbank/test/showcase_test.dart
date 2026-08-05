import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weirbank/ui/app.dart';

import 'support/flow.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every drop in them was sent by tapping a pipe, so nothing in the pictures
/// is a works the game could not reach.
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
        child: WeirbankApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the works on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'works-${phone.key}');
    });

    testWidgets('a works part set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      final most = state(tester).most;
      for (var pipe = 0; pipe < 4; pipe++) {
        for (var one = 0; one < most.down[pipe]; one++) {
          await turn(tester, pipe);
        }
      }
      await shoot(tester, 'setting-${phone.key}');
    });

    testWidgets('the cut on ${phone.key}', (tester) async {
      // Asked on an empty works, which is a fair question to ask before
      // starting: why is that the number?
      await show(tester, phone.value, which: 5);
      await press(tester, 'Why no more');
      expect(state(tester).showCut, isTrue);
      await shoot(tester, 'cut-${phone.key}');
    });
  }

  testWidgets('a pond that does not add up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await turn(tester, 0);
    await turn(tester, 0);
    expect(state(tester).play.spills, isNotEmpty);
    await shoot(tester, 'spilling');
  });

  testWidgets('the mill with all there is', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setItAll(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'running');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'works-iphone-14.png',
      'setting-iphone-14.png',
      'cut-iphone-14.png',
      'spilling.png',
      'running.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
