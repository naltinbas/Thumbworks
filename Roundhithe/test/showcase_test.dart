import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/parishland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every road in them was laid by two taps on the villages, so nothing in
/// the pictures is a plan the game could not reach.
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

    testWidgets('the ring on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await layRoads(tester, ['AB', 'BC', 'CD', 'DE', 'EF', 'FA']);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ring-${phone.key}');
    });
  }

  testWidgets('the nine roads', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layRoads(tester, ['AD', 'AE', 'AF', 'BD', 'BE', 'BF', 'CD', 'CE', 'CF']);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'nine');
  });

  testWidgets('the two trios', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layRoads(tester, ['AB', 'BC', 'CA', 'DE', 'EF', 'FD']);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'trios');
  });

  testWidgets('the eleven', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layRoads(tester, ['AB', 'AC', 'AD', 'AE', 'BC', 'BD', 'BE', 'CD', 'CE', 'DE', 'EF']);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eleven');
  });

  testWidgets('midway, a village held, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await layRoads(tester, ['AB', 'BC', 'CD', 'DE']);
    await tapVillage(tester, 4);
    expect(state(tester).play.held, 4);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the road', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layRoads(tester, ['AB']);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three each admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await layRoads(tester, ['AD', 'AE', 'AF', 'BD', 'BE', 'BF', 'CD', 'CE', 'CF', 'AB', 'AC']);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threeeach');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ring-iphone-14.png',
      'nine.png',
      'trios.png',
      'eleven.png',
      'midway.png',
      'showme.png',
      'why.png',
      'threeeach.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
