import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every leap in them was tapped, so nothing in the pictures is a
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

    testWidgets('the fourth reach reached on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await leapByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.moves, 19);
      await shoot(tester, 'fourthreach-${phone.key}');
    });
  }

  testWidgets('the first reach, one leap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await leap(tester, (0, -1), (0, 1));
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'firstreach');
  });

  testWidgets('the second reach reached by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await leap(tester, (0, -1), (0, 1));
    await leap(tester, (2, 0), (0, 0));
    await leap(tester, (0, 0), (0, 2));
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'secondreach');
  });

  testWidgets('the third reach reached', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await leapByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirdreach');
  });

  testWidgets('a reach mid-leap, a frog picked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    for (var i = 0; i < 6; i++) {
      await press(tester, 'Show me');
      final aim = state(tester).pointing!;
      await leap(tester, aim.from, aim.to);
    }
    await press(tester, 'Show me');
    final aim = state(tester).pointing!;
    await tapPad(tester, aim.from);
    expect(state(tester).play.picked, aim.from);
    await shoot(tester, 'midleap');
  });

  testWidgets('show me ringing a leap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fifth reach admitted, twelve leaps in the water',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    const leaps = [
      ((4, -1), (4, -3)),
      ((2, -2), (4, -2)), ((2, -1), (4, -1)),
      ((0, -2), (2, -2)), ((0, -1), (2, -1)),
      ((-2, -2), (0, -2)), ((-2, -1), (0, -1)),
      ((-4, -2), (-2, -2)), ((-4, -1), (-2, -1)),
      ((2, -1), (2, -3)), ((0, -1), (0, -3)), ((-2, -1), (-2, -3)),
    ];
    for (final (from, to) in leaps) {
      await leap(tester, from, to);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fifthreach');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fourthreach-iphone-14.png',
      'firstreach.png',
      'secondreach.png',
      'thirdreach.png',
      'midleap.png',
      'showme.png',
      'why.png',
      'fifthreach.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
