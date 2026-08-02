@Tags(['showcase'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wirewend/game/progress.dart';
import 'package:wirewend/ui/game_screen.dart';
import 'package:wirewend/ui/home_screen.dart';
import 'package:wirewend/ui/wire_tile.dart';

/// Renders the screens at real phone sizes and writes them out as PNGs.
///
/// This is not a golden test and nothing here can fail on a pixel: it exists
/// to produce pictures of the game for a reader. Device screenshots come from
/// a booted emulator and simulator in CI, which is the only place either can
/// run; this is the same widget tree at the same dimensions, rendered by the
/// same engine, and it is available on any machine in a couple of seconds.
///
/// Run it with: flutter test --tags showcase test/showcase_test.dart
void main() {
  const shots = 'build/showcase';

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless for a
    // picture somebody is meant to look at. Load the real face the app uses on
    // a device so these read the way the app does.
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
        loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
      }
      await loader.load();
    }
  });

  // Sizes in logical pixels, which is what a Flutter layout sees. The names
  // are the phones these match so a reader knows what they are looking at.
  const devices = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  const screen = Key('screen');

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Size size,
    Widget child, {
    int settleTaps = 0,
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(RepaintBoundary(
      key: screen,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: child,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap tiles, not every gesture detector on the screen: the back button is
    // one too, and tapping it pops to an empty route and photographs nothing.
    for (var i = 0; i < settleTaps; i++) {
      final tiles = find.byType(WireTile);
      if (tiles.evaluate().length > i) {
        await tester.tap(tiles.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }

    // Taken with a repaint boundary and written out, not compared against a
    // golden. Nothing here should ever be able to fail on a pixel: these are
    // pictures for somebody to look at, and a golden turns a change of shade
    // into a red build. The first version did compare, and every one of these
    // failed the moment it ran anywhere but the machine that made it.
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(screen));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  for (final entry in devices.entries) {
    testWidgets('the board on ${entry.key}', (tester) async {
      final progress = Progress(await SharedPreferences.getInstance());
      await shoot(
        tester,
        'board-${entry.key}',
        entry.value,
        GameScreen(level: 7, progress: progress),
      );
    });
  }

  testWidgets('the board part way through a level', (tester) async {
    final progress = Progress(await SharedPreferences.getInstance());
    await shoot(
      tester,
      'board-played',
      const Size(390, 844),
      GameScreen(level: 12, progress: progress),
      settleTaps: 6,
    );
  });

  testWidgets('the home screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{'reached': 9});
    final progress = Progress(await SharedPreferences.getInstance());
    await shoot(tester, 'home', const Size(390, 844), HomeScreen(progress: progress));
  });
}
