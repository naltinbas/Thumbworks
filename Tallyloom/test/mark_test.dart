import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyloom/game/solver.dart';
import 'package:tallyloom/ui/app.dart';
import 'package:tallyloom/ui/mark.dart';
import 'package:tallyloom/ui/palette.dart';

/// The mark, checked and then drawn.
///
/// There is no image in this repository that was not produced here. The logo
/// and the app icon are painted by the same painter that paints the board, at
/// whatever size they are asked for, which is why they cannot drift away from
/// what the game looks like.
void main() {
  test('the mark is a puzzle that can be solved', () {
    // Not decoration. If the logo of a game about puzzles that never need a
    // guess turned out to need one, that would be worth knowing.
    final solved = solve(Mark.clues);
    expect(solved.isSolved, isTrue);
    expect(solved.grid.matches(Mark.picture), isTrue);
  });

  group('drawing it', () {
    const out = 'assets';
    const screen = Key('mark');

    setUpAll(() async {
      Directory(out).createSync(recursive: true);
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
            theme: TallyloomApp.theme,
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

    testWidgets('the logo, with its numbers', (tester) async {
      await draw(
        tester,
        'logo',
        512,
        const ColoredBox(
          color: Palette.paper,
          child: Padding(padding: EdgeInsets.all(28), child: Mark()),
        ),
      );
      expect(File('$out/logo.png').lengthSync(), greaterThan(1000));
    });

    testWidgets('the icon, without them', (tester) async {
      await draw(tester, 'icon', 1024, Mark.icon());
      expect(File('$out/icon.png').lengthSync(), greaterThan(1000));
    });

    testWidgets('the icon foreground, on nothing', (tester) async {
      await draw(tester, 'icon-foreground', 1024, Mark.iconForeground());
      expect(File('$out/icon-foreground.png').lengthSync(), greaterThan(1000));
    });
  });
}
