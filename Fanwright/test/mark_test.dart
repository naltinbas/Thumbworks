import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/ui/app.dart';
import 'package:fanwright/ui/mark.dart';
import 'package:fanwright/ui/palette.dart';

/// Draws the logo and the app icon.
///
/// There is no image in this repository that was not produced here, and none
/// of them is a picture of a card: they are cards, drawn by the same shapes
/// the game draws.
void main() {
  const out = 'assets';
  const screen = Key('mark');

  setUpAll(() async {
    Directory(out).createSync(recursive: true);
    // The ranks are text, so the real face has to be loaded or the mark comes
    // out with a rectangle where the ace should be.
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
        key: screen,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: FanwrightApp.theme,
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
        color: Palette.felt,
        child: Padding(padding: EdgeInsets.all(40), child: Mark()),
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
        color: Palette.felt,
        child: Padding(padding: EdgeInsets.all(80), child: Mark()),
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
        child: Mark(onFelt: false),
      ),
    );
    expect(File('$out/icon-foreground.png').lengthSync(), greaterThan(1000));
  });
}
