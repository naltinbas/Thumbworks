import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truckleford/yard/rules.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every wagon in them was moved by working a lever, so nothing in the
/// pictures is a yard the game could not reach.
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

    testWidgets('the reversal on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await runByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'reversal-${phone.key}');
    });
  }

  testWidgets('nothing moved', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await run(tester, List.filled(Rules.wagons, Rules.roll));
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'nothing');
  });

  testWidgets('wagon one last', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await runByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onelast');
  });

  testWidgets('the odd ones first', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await runByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'odds');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await run(tester, [Rules.shunt, Rules.shunt, Rules.roll, Rules.send]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a lever', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('three, one, two given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await run(tester, [Rules.shunt, Rules.shunt, Rules.shunt, Rules.send]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothree');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'reversal-iphone-14.png',
      'nothing.png',
      'onelast.png',
      'odds.png',
      'midway.png',
      'showme.png',
      'why.png',
      'nothree.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
