import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slingwell/best_run.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/app.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_screen.dart';
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

  void asPhone(WidgetTester tester) {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);
  }

  /// Writes whatever [of] is painting into build/showcase.
  Future<void> capture(WidgetTester tester, String name, Finder of) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(of);
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> shoot(WidgetTester tester, String name, GameLoop loop) async {
    asPhone(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GameView(loop: loop),
      ),
    );
    // One frame, which the ticker spends starting its clock. Never settle:
    // the view asks for another frame forever, the way a game does.
    await tester.pump();

    await capture(
      tester,
      name,
      find.descendant(
        of: find.byType(GameView),
        matching: find.byType(RepaintBoundary),
      ),
    );
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

  // The screens around a run are the whole widget tree rather than the
  // painter, so they are photographed under a boundary of the test's own and
  // the picture has the words over the run in it.
  const screen = Key('screen');
  const thumb = Offset(195, 422);

  GameLoop loopOf(WidgetTester tester) =>
      tester.widget<GameView>(find.byType(GameView)).loop;

  Future<void> openScreen(
    WidgetTester tester, {
    Map<String, Object> saved = const {},
    int seed = 5,
  }) async {
    asPhone(tester);
    SharedPreferences.setMockInitialValues(Map<String, Object>.from(saved));
    final best = BestRun(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SlingwellApp.theme,
        home: RepaintBoundary(
          key: screen,
          child: GameScreen(best: best, seeds: () => seed),
        ),
      ),
    );
    await tester.pump();
  }

  /// A best worth beating, so both screens show what the numbers look like
  /// once a player has been at it for a while.
  const record = <String, Object>{'best.score': 31, 'best.seed': 4711};

  testWidgets('the title, over a craft already swinging', (tester) async {
    await openScreen(tester, saved: record);

    // A frame at a time rather than one long jump: the prompt fades up on a
    // real clock, and a jump photographs it wherever the jump happened to
    // land.
    for (var frame = 0; frame < 70; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    await capture(tester, 'title', find.byKey(screen));
  });

  testWidgets('a run on the glass, and the card that ends it', (tester) async {
    await openScreen(tester, saved: record);

    // Every tap here goes through the widget tree at a point on the glass,
    // which is the whole reason these two are worth taking: it is the game
    // being driven the way a thumb drives it. Finding something to tap by
    // widget type would land on whatever else answers to that type.
    await tester.tapAt(thumb);
    await tester.pump();

    var shot = false;
    for (var frame = 0; frame < 3000; frame++) {
      final world = loopOf(tester).world;
      if (world.isOver) break;
      // Aim until the climb is worth looking at, then let go at the first
      // chance, which is how a run ends.
      if (world.score < 9 ? aimed(world) : world.isHeld) {
        await tester.tapAt(thumb);
      }
      await tester.pump(const Duration(milliseconds: 8));

      final now = loopOf(tester).world;
      if (!shot && now.score >= 9 && !now.isHeld) {
        await capture(tester, 'playing', find.byKey(screen));
        shot = true;
      }
    }

    expect(shot, isTrue, reason: 'the run never got high enough to photograph');
    expect(loopOf(tester).world.isOver, isTrue, reason: 'the run never ended');

    // Long enough for the card to finish arriving over the wreck.
    await tester.pump(const Duration(milliseconds: 500));
    await capture(tester, 'game-over', find.byKey(screen));
  });
}
