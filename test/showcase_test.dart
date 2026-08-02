import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_view.dart';

/// Renders the game at a real phone size and writes the frames out as PNGs.
///
/// Nothing here can fail on a pixel and there are no golden files to keep up
/// to date: it exists to produce pictures of the game for someone to look at.
/// It is the real widget tree at real dimensions drawn by the same engine the
/// app uses, which is as close as this machine gets to a screenshot, and it
/// takes a couple of seconds instead of an emulator.
///
/// It runs with the rest of the suite, so the pictures in build/showcase are
/// always of the code as it stands. On its own:
/// flutter test test/showcase_test.dart
void main() {
  const shots = 'build/showcase';

  // A phone-shaped screen in logical pixels, which is what a layout sees.
  const size = Size(390, 844);
  const ratio = 3.0;

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test draws every glyph as a box until a real face is loaded, which
    // makes the altitude marks unreadable in a picture meant to be read.
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

  Future<void> shoot(WidgetTester tester, String name, GameLoop loop) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GameView(loop: loop),
      ),
    );
    // One frame, which the ticker spends starting its clock. Never settle:
    // the view asks for another frame forever, the way a game does.
    await tester.pump();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.descendant(
        of: find.byType(GameView),
        matching: find.byType(RepaintBoundary),
      ),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  /// Releases when the craft is pointed at where the next well will be, which
  /// is what a player who has learnt the game does. Same idea as the one the
  /// playability test uses, so these pictures are of the game being played
  /// well rather than of a craft flying into a wall.
  bool aimed(World world) {
    if (!world.isHeld) return false;
    final here = world.wells[world.heldBy!];
    Well? target;
    for (final well in world.wells) {
      if (well.at.y > here.at.y + 0.5) {
        target = well;
        break;
      }
    }
    if (target == null) return false;
    final flat = (target.at - world.craft).length;
    final flight = flat / World.launchSpeed;
    final lead = Vec(
      target.at.x,
      target.at.y + 0.5 * World.gravity * flight * flight,
    );
    final want = (lead - world.craft).normalised;
    final going = world.velocity.normalised;
    return want.x * going.x + want.y * going.y > 0.995;
  }

  /// Play until [until] says the moment is worth a picture.
  GameLoop play(
    int seed,
    bool Function(GameLoop loop) until, {
    bool badly = false,
  }) {
    final loop = GameLoop(seed: seed);
    for (var i = 0; i < 8000; i++) {
      if (badly ? loop.world.isHeld : aimed(loop.world)) loop.tap();
      loop.advance(const Duration(milliseconds: 8));
      if (until(loop)) break;
    }
    return loop;
  }

  testWidgets('the craft being swung round a well', (tester) async {
    await shoot(
      tester,
      'swinging',
      play(5, (loop) => loop.world.steps > 30),
    );
  });

  testWidgets('the moment after letting go', (tester) async {
    await shoot(
      tester,
      'released',
      play(5, (loop) => !loop.world.isHeld && loop.world.score >= 2),
    );
  });

  testWidgets('part way up a climb, over the wells already used', (
    tester,
  ) async {
    await shoot(
      tester,
      'climbing',
      play(5, (loop) => loop.world.score >= 12 && !loop.world.isHeld),
    );
  });

  testWidgets('a run thrown away by tapping at the first chance', (
    tester,
  ) async {
    // Letting go the instant a well catches is how a new player plays and how
    // a run ends, so this is the picture of losing.
    await shoot(
      tester,
      'adrift',
      play(3, (loop) => loop.world.isOver, badly: true),
    );
  });
}
