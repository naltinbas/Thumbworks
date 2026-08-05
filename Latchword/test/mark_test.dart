import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/ui/mark.dart';
import 'package:latchword/ui/palette.dart';

/// Draws the logo.
///
/// There is no image in this repository that was not produced by a test.
void main() {
  const out = 'assets';
  const frame = Key('mark');

  setUpAll(() async {
    Directory(out).createSync(recursive: true);

    // A test draws every glyph as a filled box until the real face is
    // loaded, and the letters are the whole of this picture.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    final loader = FontLoader('Roboto');
    for (final file in fonts.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.startsWith('Roboto') || !name.endsWith('.ttf')) continue;
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  });

  Future<void> draw(
    WidgetTester tester,
    String name,
    double side,
    Widget child,
  ) async {
    tester.view
      ..physicalSize = Size(side, side)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: frame,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SizedBox(width: side, height: side, child: child),
        ),
      ),
    );
    await tester.pump();

    await tester.runAsync(() async {
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(frame));
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  test('the trace in the mark is one the board would take', () {
    // The logo is the board painter given a real board and a real trace, so
    // the trace has to be a legal one: every step to a neighbour, no square
    // twice, and a word the board knows.
    final board = Mark.board;
    final trace = Mark.trace;

    expect(trace.word, 'latch');
    expect(trace.spots.toSet(), hasLength(trace.spots.length));
    for (var i = 1; i < trace.spots.length; i++) {
      expect(trace.spots[i - 1].touches(trace.spots[i]), isTrue,
          reason: 'step $i jumps');
    }
    expect(board.judge(trace.spots), Refusal.none);
  });

  testWidgets('the logo', (tester) async {
    await draw(
      tester,
      'logo',
      512,
      const ColoredBox(
        color: Palette.backdrop,
        child: Padding(padding: EdgeInsets.all(10), child: Mark()),
      ),
    );
    expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
  });
}
