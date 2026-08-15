import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every peg in them was tapped, so nothing in the pictures is a board
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
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the cross cords landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setPegs(tester, [(0, 0), (3, 0), (4, 2), (2, 2)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'crosscords-${phone.key}');
    });
  }

  testWidgets('the even cords landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setPegs(tester, [(0, 0), (4, 0), (4, 2), (0, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'evencords');
  });

  testWidgets('the square cords landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setPegs(tester, [(2, 0), (4, 2), (2, 4), (0, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'squarecords');
  });

  testWidgets('the fourth peg landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourthpeg');
  });

  testWidgets('a board mid-cording, three pegs set', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setPegs(tester, [(0, 1), (3, 0), (4, 3)]);
    expect(state(tester).play.pegs, hasLength(3));
    await shoot(tester, 'midcording');
  });

  testWidgets('show me ringing a hole', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the skew admitted, a parallelogram standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 2)]);
    for (var dither = 0; dither < 4; dither++) {
      await setPegs(tester, [(1, 2), (1, 2)]);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.figure, 'a parallelogram');
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'skew');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'crosscords-iphone-14.png',
      'evencords.png',
      'squarecords.png',
      'fourthpeg.png',
      'midcording.png',
      'showme.png',
      'why.png',
      'skew.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
