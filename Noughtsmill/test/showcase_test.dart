import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/millstead.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every winding in them was pressed, so nothing in the pictures is
/// a mill the game could not reach.
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
    testWidgets('the mill on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'mill-${phone.key}');
    });

    testWidgets('the hundred ground on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await windTo(tester, 100);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'hundred-${phone.key}');
    });
  }

  testWidgets('the first nought ground', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await windTo(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'firstnought');
  });

  testWidgets('the jump past four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await windTo(tester, 24);
    expect(state(tester).play.noughts, 4);
    await shoot(tester, 'jump');
  });

  testWidgets('show me pointing a winding', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fifth nought admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var winding = 0; winding < 24; winding++) {
      await press(tester, winding.isEven ? '+1' : '-1');
    }
    await shoot(tester, 'fifthnought');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'mill-iphone-14.png',
      'hundred-iphone-14.png',
      'firstnought.png',
      'jump.png',
      'showme.png',
      'why.png',
      'fifthnought.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
