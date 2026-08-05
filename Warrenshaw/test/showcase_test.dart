import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warrenshaw/chase/maps.dart';
import 'package:warrenshaw/ui/app.dart';

import 'support/chase.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every move in them was made by tapping a place, and every reply came from
/// the table, so nothing in the pictures is a position the game could not
/// reach.
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
        child: WarrenshawApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the maps on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'maps-${phone.key}');
    });

    testWidgets('a chase part run on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await touch(tester, state(tester).play.next!);
      await touch(tester, state(tester).play.next!);
      await shoot(tester, 'chasing-${phone.key}');
    });

    testWidgets('being shown a move on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      await touch(tester, state(tester).play.next!);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNonNegative);
      await shoot(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a move that wastes time', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    final play = state(tester).play;
    final wrong = [
      for (final place in play.canGo)
        if (place != play.next) place,
    ];
    await touch(tester, wrong.first);
    expect(state(tester).play.wasted, greaterThan(0));
    await shoot(tester, 'wasted');
  });

  testWidgets('the one nobody can win', (tester) async {
    await show(tester, phones['iphone-14']!, which: Warrens.count - 1);
    for (var turn = 0; turn < 3; turn++) {
      final play = state(tester).play;
      await touch(tester, play.canGo.firstWhere((at) => at != play.seeker));
    }
    await press(tester, 'Show me');
    await shoot(tester, 'hopeless');
  });

  testWidgets('caught', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await chaseItDown(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'caught');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'maps-iphone-14.png',
      'chasing-iphone-14.png',
      'shown-iphone-14.png',
      'wasted.png',
      'hopeless.png',
      'caught.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
