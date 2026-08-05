import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeinmoor/thread/boards.dart';
import 'package:skeinmoor/ui/app.dart';

import 'support/thread.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every cell that has wool on it in them was drawn there through the screen,
/// so nothing in the pictures is a board the game could not reach.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    for (final family in const ['Roboto', 'MaterialIcons']) {
      final loader = FontLoader(family);
      for (final file in fonts.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (!name.startsWith(family)) continue;
        if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
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
        child: SkeinmoorApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  /// Draws part of the board, a thread at a time, the way a finger would.
  Future<void> drawOn(WidgetTester tester, int threads) async {
    final answer = state(tester).guide.answer;
    for (var thread = 0; thread < threads && thread < answer.length; thread++) {
      await dragThrough(tester, answer[thread]);
    }
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

    testWidgets('a board part drawn on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 10);
      await drawOn(tester, 3);
      // And one thread left in the middle of being drawn.
      final want = state(tester).guide.answer[3];
      await dragThrough(tester, want.take(want.length - 2).toList());
      await shoot(tester, 'drawing-${phone.key}');
    });

    testWidgets('being shown a cell on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      await drawOn(tester, 2);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      await shoot(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('joined up, and still not finished', (tester) async {
    final which = await lazyFillSomething(tester, Boards.count);
    expect(which, isNonNegative);
    // lazyFill opens the app itself, so this puts it in a boundary to shoot.
    expect(state(tester).play.joined, state(tester).play.field.threads);
    expect(state(tester).play.empty, greaterThan(0));
    await shoot(tester, 'left-over');
  });

  testWidgets('a board filled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await fillIt(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'filled');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'boards-iphone-14.png',
      'drawing-iphone-14.png',
      'shown-iphone-14.png',
      'left-over.png',
      'filled.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
