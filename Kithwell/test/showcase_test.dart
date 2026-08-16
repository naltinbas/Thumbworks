import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fairland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every friendship in them was made by two taps on the people, so nothing
/// in the pictures is a plan the game could not reach.
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

    testWidgets('the widest gap on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await befriend(tester, [(0, 1), (0, 2), (0, 3), (0, 4), (0, 5)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'widest-${phone.key}');
    });
  }

  testWidgets('the even fair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await befriend(tester, [(0, 1), (2, 3), (4, 5)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'even');
  });

  testWidgets('the gap of one', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await befriend(tester, [(0, 1), (0, 2), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'one');
  });

  testWidgets('the half', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await befriend(tester, [(0, 2), (0, 3), (0, 4), (0, 5), (1, 2), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'half');
  });

  testWidgets('midway, a person held, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await befriend(tester, [(0, 1), (2, 3)]);
    await tapPerson(tester, 4);
    expect(state(tester).play.held, 4);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the friendship', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await befriend(tester, [(1, 2)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the popular few admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await befriend(tester, [(0, 1), (2, 3), (4, 5), (0, 1), (2, 3), (0, 2), (1, 3), (0, 2), (1, 3), (0, 3), (1, 2)]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'popular');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'widest-iphone-14.png',
      'even.png',
      'one.png',
      'half.png',
      'midway.png',
      'showme.png',
      'why.png',
      'popular.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
