import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every tap in them was tapped, so nothing in the pictures is a
/// dialling the game could not reach.
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
    testWidgets('the worth on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'worth-${phone.key}');
    });

    testWidgets('the seven turns dark on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await dialTo(tester, 1, 1);
      await dialTo(tester, 2, 3);
      await dialTo(tester, 3, 7);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'seventurns-${phone.key}');
    });
  }

  testWidgets('the one turn dark', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    for (var window = 0; window < 4; window++) {
      await tapWindow(tester, window);
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oneturn');
  });

  testWidgets('the common lot dark', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await darkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'commonlot');
  });

  testWidgets('the three alike dark', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    for (var window = 0; window < 3; window++) {
      await tapWindow(tester, window);
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threealike');
  });

  testWidgets('a house mid-dial, circling', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapWindow(tester, 0);
    await tapWindow(tester, 1);
    expect(state(tester).play.turns, -1);
    await shoot(tester, 'circling');
  });

  testWidgets('show me ringing a window', (tester) async {
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

  testWidgets('the three turns admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // A circling dialling standing, its ring written below;
    // dither one window till the worth admits.
    await dialTo(tester, 0, 1);
    await dialTo(tester, 1, 2);
    await dialTo(tester, 2, 3);
    for (var dither = 0; dither < 8; dither++) {
      await tapWindow(tester, 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threeturns');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'worth-iphone-14.png',
      'seventurns-iphone-14.png',
      'oneturn.png',
      'commonlot.png',
      'threealike.png',
      'circling.png',
      'showme.png',
      'why.png',
      'threeturns.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
