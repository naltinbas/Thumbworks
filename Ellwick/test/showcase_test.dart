import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rungland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pair in them was set by taps and climbs, so nothing in the
/// pictures is a setting the game could not reach.
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

    testWidgets('the thousandth on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await measureByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'thousandth-${phone.key}');
    });
  }

  testWidgets('the one over', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await turn(tester, 'diagonal', -1);
    await climb(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oneover');
  });

  testWidgets('the one under', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await measureByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oneunder');
  });

  testWidgets('the record', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setDials(tester, 5, 7);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'record');
  });

  testWidgets('midway, off the ladder, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setDials(tester, 3, 4);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting the ladder', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await turn(tester, 'diagonal', -1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the true diagonal admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await turn(tester, 'diagonal', -1);
    for (var k = 0; k < 5; k++) {
      await climb(tester);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'truediagonal');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'thousandth-iphone-14.png',
      'oneover.png',
      'oneunder.png',
      'record.png',
      'midway.png',
      'showme.png',
      'why.png',
      'truediagonal.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
