import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pailsworth/pail/play.dart';

import 'support/fonts.dart';
import 'support/pail.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every pour in them was tapped, so nothing in the pictures is a
/// waterline the game could not reach.
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
    testWidgets('the errands on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'errands-${phone.key}');
    });

    testWidgets('the even hand mid-pour on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      for (var pour = 0; pour < 3; pour++) {
        final next = state(tester).play.next!;
        await pourFrom(tester, next.$1, next.$2);
      }
      await shoot(tester, 'pouring-${phone.key}');
    });

    testWidgets('an errand run on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await runItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'run-${phone.key}');
    });
  }

  testWidgets('a pail armed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await pourFrom(tester, Play.spring, 1);
    await tapEnd(tester, 1);
    expect(state(tester).armed, 1);
    await shoot(tester, 'armed');
  });

  testWidgets('a pour pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'pointed');
  });

  testWidgets('the third pint measured out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await pourFrom(tester, Play.spring, 1);
    await pourFrom(tester, 1, 0);
    await press(tester, 'Why');
    await shoot(tester, 'thirdpint');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'errands-iphone-14.png',
      'pouring-iphone-14.png',
      'run-iphone-14.png',
      'armed.png',
      'pointed.png',
      'thirdpint.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
