import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hillside.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every plant in them was swapped by taps, so nothing in the
/// pictures is a hillside the game could not reach.
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
    testWidgets('the hillside on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hillside-${phone.key}');
    });

    testWidgets('the eleven planted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await plantByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'eleven-${phone.key}');
    });
  }

  testWidgets('the first patch landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    final spot = state(tester).play.rules.inner.single;
    await tapSpot(tester, spot.$1, spot.$2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'firstpatch');
  });

  testWidgets('the nine mid-planting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    final spots = state(tester).play.rules.inner;
    await tapSpot(tester, spots[0].$1, spots[0].$2);
    await tapSpot(tester, spots[2].$1, spots[2].$2);
    await tapSpot(tester, spots[2].$1, spots[2].$2);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midplant');
  });

  testWidgets('show me pointing a spot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the even hill admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    final spot = state(tester).play.rules.inner.first;
    for (var replant = 0; replant < 12; replant++) {
      await tapSpot(tester, spot.$1, spot.$2);
    }
    await shoot(tester, 'evenhill');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hillside-iphone-14.png',
      'eleven-iphone-14.png',
      'firstpatch.png',
      'midplant.png',
      'showme.png',
      'why.png',
      'evenhill.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
