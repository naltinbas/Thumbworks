import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leystone/ley/rules.dart';

import 'support/fonts.dart';
import 'support/ley.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every ring in them was raised berth by berth, so nothing in the
/// pictures is a green the game could not reach.
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
    testWidgets('the greens on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'greens-${phone.key}');
    });

    testWidgets('the ten mid-raising on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      for (var stone = 0; stone < 6; stone++) {
        final play = state(tester).play;
        await tapBerth(tester, play.nextOf(play.finished!)!);
      }
      await shoot(tester, 'raising-${phone.key}');
    });

    testWidgets('a ring standing on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await raiseIt(tester);
      await shoot(tester, 'standing-${phone.key}');
    });
  }

  testWidgets('a ley drawn through a refusal', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapBerth(tester, (0, 0));
    await tapBerth(tester, (1, 1));
    await tapBerth(tester, (2, 2));
    expect(state(tester).ley, isNotNull);
    await shoot(tester, 'ley');
  });

  testWidgets('the counting spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd stone jammed at six', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final berth in Rules.complete(3, const [], 6)!) {
      await tapBerth(tester, berth);
    }
    expect(state(tester).stuck, isTrue);
    await shoot(tester, 'oddstone');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'greens-iphone-14.png',
      'raising-iphone-14.png',
      'standing-iphone-14.png',
      'ley.png',
      'why.png',
      'oddstone.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
