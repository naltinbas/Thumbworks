import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/alley.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every knock in them was tapped, so nothing in the pictures is an
/// alley the game could not reach.
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

  Future<void> show(WidgetTester tester, Size size, {int? which}) =>
      open(tester, which: which, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the alleys on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'alleys-${phone.key}');
    });

    testWidgets('the three frames mid-bowl on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      final knock = state(tester).play.zeroing!;
      if (knock.$3 < 0) {
        await knockOne(tester, knock.$1, knock.$2);
      } else {
        await knockTwo(tester, knock.$1, knock.$2, knock.$3);
      }
      await shoot(tester, 'bowling-${phone.key}');
    });

    testWidgets('an alley won on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await bowlItHome(tester);
      expect(state(tester).won, isTrue);
      await shoot(tester, 'won-${phone.key}');
    });
  }

  testWidgets('a skittle armed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapPin(tester, 0, 5);
    expect(state(tester).armed, isNotNull);
    await shoot(tester, 'armedpin');
  });

  testWidgets('the counts chipped gold', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showCounts, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the even alley mid-mirror', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await knockTwo(tester, 0, 2, 3);
    await press(tester, 'Why');
    await shoot(tester, 'evenalley');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'alleys-iphone-14.png',
      'bowling-iphone-14.png',
      'won-iphone-14.png',
      'armedpin.png',
      'why.png',
      'evenalley.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
