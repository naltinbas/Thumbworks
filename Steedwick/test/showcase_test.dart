import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every move in them was tapped, so nothing in the pictures is a
/// standing the game could not reach.
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

    testWidgets('the colour swap ridden on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await rideByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'colourswap-${phone.key}');
    });
  }

  testWidgets('the errand ridden', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await ride(tester, 2, 1);
    await ride(tester, 0, 5);
    await ride(tester, 0, 6);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'errand');
  });

  testWidgets('the quarter turn ridden', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await rideByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'quarterturn');
  });

  testWidgets('the pales down ridden', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await rideByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'palesdown');
  });

  testWidgets('a paddock mid-ride, a steed picked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await ride(tester, 0, 5);
    await ride(tester, 2, 1);
    await tapStall(tester, 8);
    expect(state(tester).play.picked, 3);
    await shoot(tester, 'midride');
  });

  testWidgets('show me ringing a move', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the pale swap admitted, twelve moves ridden', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var i = 0; i < 6; i++) {
      await ride(tester, 0, 5);
      await ride(tester, 0, 0);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'paleswap');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'colourswap-iphone-14.png',
      'errand.png',
      'quarterturn.png',
      'palesdown.png',
      'midride.png',
      'showme.png',
      'why.png',
      'paleswap.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
