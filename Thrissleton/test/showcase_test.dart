import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/letonland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every stone in them was tapped, so nothing in the pictures is a
/// hand the game could not reach.
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
    testWidgets('the leton on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'leton-${phone.key}');
    });

    testWidgets('the perfect ten dialled on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await dialByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'perfectten-${phone.key}');
    });
  }

  testWidgets('the four thirds dialled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapStone(tester, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourthirds');
  });

  testWidgets('the one third dialled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onethird');
  });

  testWidgets('the locked six dialled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lockedsix');
  });

  testWidgets('a hand mid-dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapStone(tester, 0);
    await tapStone(tester, 1);
    expect(state(tester).play.moves, 2);
    await shoot(tester, 'middial');
  });

  testWidgets('show me ringing a stone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the empty hand admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var dither = 0; dither < 15; dither++) {
      await tapStone(tester, dither % 5);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'emptyhand');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'leton-iphone-14.png',
      'perfectten-iphone-14.png',
      'fourthirds.png',
      'onethird.png',
      'lockedsix.png',
      'middial.png',
      'showme.png',
      'why.png',
      'emptyhand.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
