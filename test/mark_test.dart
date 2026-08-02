import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultline/ui/app.dart';
import 'package:vaultline/ui/mark.dart';
import 'package:vaultline/ui/palette.dart';

/// Draws the logo and the app icon.
///
/// There is no image in this repository that was not produced here.
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
          theme: VaultlineApp.theme,
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
        color: Palette.sky,
        child: Padding(padding: EdgeInsets.all(36), child: Mark()),
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
        color: Palette.sky,
        child: Padding(padding: EdgeInsets.all(70), child: Mark()),
      ),
    );
    expect(File('$out/icon.png').lengthSync(), greaterThan(1000));
  });

  testWidgets('the adaptive icon foreground, on nothing', (tester) async {
    await draw(
      tester,
      'icon-foreground',
      1024,
      const Padding(
        padding: EdgeInsets.all(240),
        child: Mark(onSky: false),
      ),
    );
    expect(File('$out/icon-foreground.png').lengthSync(), greaterThan(1000));
  });
}
