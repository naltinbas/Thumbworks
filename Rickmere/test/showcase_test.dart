import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rickland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every post in them was stood by a tap on a peg, so nothing in the
/// pictures is a field the game could not reach.
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
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the widest ring on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await standByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'widest-${phone.key}');
    });
  }

  testWidgets('the square corner', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'square');
  });

  testWidgets('six acres', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('the square six', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'squaresix');
  });

  testWidgets('a post in hand, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await tapPeg(tester, (0, 2));
    expect(state(tester).play.lifted, 0);
    await shoot(tester, 'inhand');
  });

  testWidgets('show me lighting a post', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the uneven three given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final peg in [(4, 4), (0, 0), (4, 0), (3, 3)]) {
      await movePost(tester, state(tester).play.posts[0], peg);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'uneven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'widest-iphone-14.png',
      'square.png',
      'six.png',
      'squaresix.png',
      'inhand.png',
      'showme.png',
      'why.png',
      'uneven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
