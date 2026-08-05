import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hollowmarch/pegs/boards.dart';
import 'package:hollowmarch/pegs/play.dart';
import 'package:hollowmarch/ui/app.dart';

import 'support/fonts.dart';
import 'support/pegs.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every peg that has gone in them went by being jumped over, so nothing in
/// the pictures is a position the game could not reach.
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
        child: HollowmarchApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the boards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'boards-${phone.key}');
    });

    testWidgets('a board part played on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 10);
      await playSome(tester, 12);
      await shoot(tester, 'playing-${phone.key}');
    });

    testWidgets('being shown a jump on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 8);
      await playSome(tester, 4);
      await letGo(tester);
      await press(tester, 'Show me');
      expect(state(tester).pointing, hasLength(2));
      await shoot(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a jump that spoils the board', (tester) async {
    var found = false;
    for (var which = 0; which < Boards.count && !found; which++) {
      await show(tester, phones['iphone-14']!, which: which);
      final board = state(tester).board;
      final guide = state(tester).guide;

      for (final jump in state(tester).play.canJump) {
        final after = Play.of(board).jump(jump.from, jump.to);
        if (guide.canStillFinish(after.pegs) != false) continue;
        await hop(tester, jump);
        found = true;
        break;
      }
    }
    expect(found, isTrue);
    expect(state(tester).saying, isNotNull);
    await shoot(tester, 'spoiled');
  });

  testWidgets('one peg left', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await playItOut(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'one-left');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'boards-iphone-14.png',
      'playing-iphone-14.png',
      'shown-iphone-14.png',
      'spoiled.png',
      'one-left.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
