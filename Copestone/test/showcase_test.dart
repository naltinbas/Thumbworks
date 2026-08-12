import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wall.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every wall in them was laid course by course, so nothing in the
/// pictures is a pitch the game could not reach.
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
    testWidgets('the pitches on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'pitches-${phone.key}');
    });

    testWidgets('the dozen mid-raising on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      for (var course = 0; course < 7; course++) {
        await lay(tester, state(tester).play.next!);
      }
      await shoot(tester, 'raising-${phone.key}');
    });

    testWidgets('a wall stood on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await raiseIt(tester);
      await shoot(tester, 'stood-${phone.key}');
    });
  }

  testWidgets('a doubled run marked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lay(tester, 0);
    await lay(tester, 1);
    await lay(tester, 0);
    await lay(tester, 1);
    expect(state(tester).doubled, isNotNull);
    await shoot(tester, 'doubled');
  });

  testWidgets('the palindrome penned in', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    for (final kind in const [0, 1, 0, 2, 0, 1, 0]) {
      await lay(tester, kind);
    }
    expect(state(tester).play.pennedIn, isTrue);
    await shoot(tester, 'penned');
  });

  testWidgets('the fourth course refused forever', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lay(tester, 0);
    await lay(tester, 1);
    await lay(tester, 0);
    expect(state(tester).play.pennedIn, isTrue);
    await shoot(tester, 'fourth');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'pitches-iphone-14.png',
      'raising-iphone-14.png',
      'stood-iphone-14.png',
      'doubled.png',
      'penned.png',
      'fourth.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
