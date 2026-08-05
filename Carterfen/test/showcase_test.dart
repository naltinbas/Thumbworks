import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carterfen/ui/app.dart';

import 'support/round.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every call in them was made by tapping a farm, so nothing in the pictures
/// is a round the game could not reach.
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
        child: CarterfenApp(key: ValueKey(opened++), opensAt: which),
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

    testWidgets('a round part driven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var call = 0; call < 5; call++) {
        await driveTo(tester, state(tester).play.next!);
      }
      await shoot(tester, 'driving-${phone.key}');
    });

    testWidgets('one that is home on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await driveItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'home-${phone.key}');
    });
  }

  testWidgets('a call that costs something', (tester) async {
    await show(tester, phones['iphone-14']!, which: 7);
    for (var stop = 1; stop < state(tester).play.count; stop++) {
      await show(tester, phones['iphone-14']!, which: 7);
      await driveTo(tester, stop);
      final play = state(tester).play;
      if (play.gone + play.restOfIt.length > play.round.shortest) break;
    }
    expect(state(tester).saying, isNotNull);
    await shoot(tester, 'costly');
  });

  testWidgets('being shown the next farm', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await driveTo(tester, state(tester).play.next!);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNonNegative);
    await shoot(tester, 'shown');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rounds-iphone-14.png',
      'driving-iphone-14.png',
      'home-iphone-14.png',
      'costly.png',
      'shown.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
