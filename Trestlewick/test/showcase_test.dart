import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trestlewick/ui/app.dart';

import 'support/raise.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every timber standing in them was raised by tapping it, so nothing in the
/// pictures is a site the game could not reach.
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
        child: TrestlewickApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the frames on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'frames-${phone.key}');
    });

    testWidgets('a frame part raised on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      for (var day = 0; day < 3; day++) {
        await press(tester, 'Show me');
        await press(tester, 'Raise the day');
      }
      await press(tester, 'Show me');
      await shoot(tester, 'raising-${phone.key}');
    });

    testWidgets('one standing on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await raiseItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'standing-${phone.key}');
    });
  }

  testWidgets('being shown the run that holds it back', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showRun, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a timber that is waiting on something', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await put(tester, 8);
    expect(state(tester).saying, contains('rests on'));
    await shoot(tester, 'waiting');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'frames-iphone-14.png',
      'raising-iphone-14.png',
      'standing-iphone-14.png',
      'why.png',
      'waiting.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
