import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every hand in them was tapped round, so nothing in the pictures is
/// a rota the game could not reach.
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

  Future<void> finishByHand(WidgetTester tester, int which) async {
    final aim = Rules(4, Rotas.at(which).fixed).landing()!;
    for (final entry in aim.entries) {
      if (Rotas.at(which).fixed.containsKey(entry.key)) continue;
      await setHand(tester, entry.key, entry.value);
    }
  }

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

    testWidgets('the four fixed finished on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await finishByHand(tester, 3);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fourfixed-${phone.key}');
    });
  }

  testWidgets('the first day finished', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'firstday');
  });

  testWidgets('the three fixed finished', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threefixed');
  });

  testWidgets('the diagonal finished', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await finishByHand(tester, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'diagonal');
  });

  testWidgets('a rota mid-fill, one clash', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setHand(tester, (1, 0), 3);
    await setHand(tester, (1, 1), 4);
    await setHand(tester, (1, 2), 4);
    expect(state(tester).play.clashes, hasLength(2));
    await shoot(tester, 'midfill');
  });

  testWidgets('show me ringing a shift', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the stuck shift admitted, hand 4 clashing down the station',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var tap = 0; tap < 14; tap++) {
      await tapShift(tester, (0, 3));
    }
    expect(state(tester).play.moves, 14);
    expect(state(tester).play.filled[(0, 3)], 4);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'stuckshift');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fourfixed-iphone-14.png',
      'firstday.png',
      'threefixed.png',
      'diagonal.png',
      'midfill.png',
      'showme.png',
      'why.png',
      'stuckshift.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
