import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fen.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every move in them was tapped, so nothing in the pictures is a
/// village the game could not reach.
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

  Future<void> followShown(WidgetTester tester) async {
    final aim = state(tester).play.next!;
    await press(tester, 'Show me');
    await tapHouse(tester, aim.$1);
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the fen on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fen-${phone.key}');
    });

    testWidgets('the charity as it opens on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await shoot(tester, 'charity-${phone.key}');
    });
  }

  testWidgets('the lane settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapHouse(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'settled');
  });

  testWidgets('the long settlement two moves in', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await followShown(tester);
    await followShown(tester);
    expect(state(tester).play.moves, 2);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'longway');
  });

  testWidgets('show me pointing a borrowing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the short pound admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var move = 0; move < 12; move++) {
      await tapHouse(tester, move % 3);
    }
    await shoot(tester, 'shortpound');
  });

  testWidgets('the green mid-settle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await followShown(tester);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'green');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fen-iphone-14.png',
      'charity-iphone-14.png',
      'settled.png',
      'longway.png',
      'showme.png',
      'why.png',
      'shortpound.png',
      'green.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
