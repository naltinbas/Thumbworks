import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/griddle.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every stack in them was reached by tapping cakes, so nothing in the
/// pictures is a batch the game could not reach.
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
    testWidgets('the batches on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'batches-${phone.key}');
    });

    testWidgets('a batch part flipped on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await flip(tester, state(tester).play.next!);
      await flip(tester, state(tester).play.next!);
      await shoot(tester, 'flipping-${phone.key}');
    });

    testWidgets('one served on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await serveItAll(tester);
      expect(state(tester).play.isServed, isTrue);
      await shoot(tester, 'served-${phone.key}');
    });
  }

  testWidgets('the gaps carrying the number', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).showGaps, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the slack batch owning the shortfall', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'slack');
  });

  testWidgets('a wasted flip called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    final play = state(tester).play;
    var wasted = -1;
    for (var under = 0; under <= 3; under++) {
      if (play.flip(under).couldStillBe > play.batch.fewest) {
        wasted = under;
        break;
      }
    }
    await flip(tester, wasted);
    expect(state(tester).saying, contains('more than'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'batches-iphone-14.png',
      'flipping-iphone-14.png',
      'served-iphone-14.png',
      'why.png',
      'slack.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
