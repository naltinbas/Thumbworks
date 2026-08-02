import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/ui/app.dart';
import 'package:thornguard/ui/mark.dart';
import 'package:thornguard/ui/palette.dart';

/// Draws the logo and the app icon.
///
/// There is no image in this repository that was not produced here. Both are
/// painted by the same code that paints the board, at whatever size they are
/// asked for, which is why they cannot drift away from what the game looks
/// like.
void main() {
  const out = 'assets';
  const screen = Key('mark');

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
        key: screen,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThornguardApp.theme,
          home: SizedBox(width: side, height: side, child: child),
        ),
      ),
    );
    await tester.pump();

    await tester.runAsync(() async {
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(screen));
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  testWidgets('the logo', (tester) async {
    await draw(
      tester,
      'logo',
      512,
      const ColoredBox(
        color: Palette.night,
        child: Padding(padding: EdgeInsets.all(52), child: Mark()),
      ),
    );
    expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the app icon', (tester) async {
    await draw(
      tester,
      'icon',
      1024,
      const ColoredBox(
        color: Palette.night,
        child: Padding(padding: EdgeInsets.all(96), child: Mark()),
      ),
    );
    expect(File('$out/icon.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the adaptive icon foreground, on nothing', (tester) async {
    // An adaptive icon shows about the middle two thirds, whatever shape this
    // year's launcher crops it to, so the mark sits inside a little over half.
    await draw(
      tester,
      'icon-foreground',
      1024,
      const Padding(
        padding: EdgeInsets.all(250),
        child: Mark(onBoard: false),
      ),
    );
    expect(File('$out/icon-foreground.png').lengthSync(), greaterThan(1000));
  });
}
