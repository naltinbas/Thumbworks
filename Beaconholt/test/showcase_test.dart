import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beaconholt/ui/app.dart';

import 'support/watch.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every beacon in them was lit by tapping a hill, so nothing in the pictures
/// is a country the game could not reach.
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
        child: BeaconholtApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the countries on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'countries-${phone.key}');
    });

    testWidgets('a country part lit on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      await light(tester, state(tester).play.next!);
      await shoot(tester, 'lighting-${phone.key}');
    });

    testWidgets('one that is watched on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await lightItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'watched-${phone.key}');
    });
  }

  testWidgets('a beacon in the wrong place', (tester) async {
    // The hill that watches the most, which on every country here but the
    // first is not a hill in any smallest set.
    await show(tester, phones['iphone-14']!, which: 3);
    var best = 0;
    var most = 0;
    final play = state(tester).play;
    for (var hill = 0; hill < play.count; hill++) {
      var lights = 0;
      for (var other = 0; other < play.count; other++) {
        if (play.country.sees(hill, other)) lights++;
      }
      if (lights > most) {
        most = lights;
        best = hill;
      }
    }
    await light(tester, best);
    await shoot(tester, 'greedy');
  });

  testWidgets('being shown a hill', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
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
      'countries-iphone-14.png',
      'lighting-iphone-14.png',
      'watched-iphone-14.png',
      'greedy.png',
      'shown.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
