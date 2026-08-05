import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/mark.dart';
import 'package:slingwell/ui/palette.dart';

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

  test('the run in the mark is a real one, let go and still flying', () {
    // The logo is a run rather than a picture of one, so it can be asked
    // the same questions a run can: it let go, it is climbing, and it has
    // not hit anything.
    final (world, trail) = Mark.run;

    expect(world.ending, Ending.none);
    expect(world.heldBy, isNull, reason: 'it let go');
    expect(world.craft.y, greaterThan(0), reason: 'and it is climbing');
    expect(trail.points.length, greaterThan(8));
  });

  testWidgets('the logo', (tester) async {
    await draw(
      tester,
      'logo',
      512,
      const ColoredBox(color: Palette.skyBottom, child: Mark()),
    );
    expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
  });
}
