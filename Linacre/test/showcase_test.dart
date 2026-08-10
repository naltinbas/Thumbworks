import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linacre/ui/app.dart';
import 'package:linacre/wire/rounds.dart';

import 'support/wire.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every cut and every brace in them was played by tapping a wire, with the
/// machine answering for real, so nothing in the pictures is a position the
/// game could not reach.
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

  var opened = 0;

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: LinacreApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the rounds on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rounds-${phone.key}');
    });

    testWidgets('a round mid game on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await touch(tester, state(tester).play.next!);
      await touch(tester, state(tester).play.next!);
      await shoot(tester, 'playing-${phone.key}');
    });

    testWidgets('one won on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await winItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'won-${phone.key}');
    });
  }

  testWidgets('the two webs on the round that cannot be won', (tester) async {
    final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
    await show(tester, phones['iphone-14']!, which: hopeless);
    await press(tester, 'Why');
    expect(state(tester).webs, isNotNull);
    await shoot(tester, 'why');
  });

  testWidgets('the machine answering a cut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await touch(tester, state(tester).play.next!);
    expect(state(tester).saying, contains('He braced'));
    await shoot(tester, 'answered');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rounds-iphone-14.png',
      'playing-iphone-14.png',
      'won-iphone-14.png',
      'why.png',
      'answered.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
