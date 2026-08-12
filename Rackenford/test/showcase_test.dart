import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/pantryland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every lift in them was tapped, so nothing in the pictures is a
/// racking the game could not reach.
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
    testWidgets('the larder on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'larder-${phone.key}');
    });

    testWidgets('the dozen racked on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await rackByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'dozen-${phone.key}');
    });
  }

  testWidgets('the six racked home', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('the eight racked home', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eight');
  });

  testWidgets('the ten racked home', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ten');
  });

  testWidgets('a quarrel standing sore', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapJar(tester, 0);
    await tapJar(tester, 1);
    expect(state(tester).play.quarrels, hasLength(1));
    await shoot(tester, 'quarrel');
  });

  testWidgets('show me ringing a jar', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the dozen on three admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Rack the chain of four first: one, two, four on the
    // three racks, and eight has nowhere clean; dither it
    // round the clock till the pantry admits.
    await liftTo(tester, 0, 1);
    await liftTo(tester, 1, 2);
    await liftTo(tester, 3, 3);
    for (var dither = 0; dither < 18; dither++) {
      await tapJar(tester, 7);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'dozenthree');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'larder-iphone-14.png',
      'dozen-iphone-14.png',
      'six.png',
      'eight.png',
      'ten.png',
      'quarrel.png',
      'showme.png',
      'why.png',
      'dozenthree.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
