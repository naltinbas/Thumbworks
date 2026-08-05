import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/ui/mark.dart';
import 'package:wirewend/ui/palette.dart';

/// Draws the logo.
///
/// There is no image in this repository that was not produced by a test.
void main() {
  const out = 'assets';
  const frame = Key('mark');

  setUpAll(() => Directory(out).createSync(recursive: true));

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

  test('the four cells in the mark really do join up', () {
    // The logo is the game's own painter, so the wire in it has to obey the
    // rule the board obeys: every end of every cell meets an end of the cell
    // next to it.
    final cells = Mark.cells;
    final board = Board(rows: 2, cols: 2, cells: cells);

    expect(board.at(0, 0).ends.has(Ends.south), isTrue);
    expect(board.at(1, 0).ends.has(Ends.north), isTrue);
    expect(board.at(0, 0).ends.has(Ends.east), isTrue);
    expect(board.at(0, 1).ends.has(Ends.west), isTrue);
    expect(board.at(0, 1).ends.has(Ends.south), isTrue);
    expect(board.at(1, 1).ends.has(Ends.north), isTrue);

    // And the lamp is lit, which is the whole point of the picture.
    expect(board.isSolved, isTrue);
  });

  testWidgets('the logo', (tester) async {
    await draw(
      tester,
      'logo',
      512,
      const ColoredBox(
        color: Palette.backdrop,
        child: Padding(padding: EdgeInsets.all(26), child: Mark()),
      ),
    );
    expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
  });
}
