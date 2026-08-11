import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ruler.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every notch in them was tapped, so nothing in the pictures is a rule
/// the game could not reach.
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
    testWidgets('the rulers on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rulers-${phone.key}');
    });

    testWidgets('the eleven mid-cut on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await tapMark(tester, state(tester).play.next!);
      await tapMark(tester, state(tester).play.next!);
      await tapMark(tester, state(tester).play.next!);
      await shoot(tester, 'cutting-${phone.key}');
    });

    testWidgets('a ruler cut true on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await cutItTrue(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'true-${phone.key}');
    });
  }

  testWidgets('a doubled length red in the census', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapMark(tester, 0);
    await tapMark(tester, 1);
    await tapMark(tester, 2);
    await shoot(tester, 'doubled');
  });

  testWidgets('a mend pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNot(-1));
    await shoot(tester, 'pointed');
  });

  testWidgets('the perfect ten counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapMark(tester, 0);
    await tapMark(tester, 1);
    await tapMark(tester, 4);
    await tapMark(tester, 9);
    await tapMark(tester, 10);
    await press(tester, 'Why');
    await shoot(tester, 'perfectten');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rulers-iphone-14.png',
      'cutting-iphone-14.png',
      'true-iphone-14.png',
      'doubled.png',
      'pointed.png',
      'perfectten.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
