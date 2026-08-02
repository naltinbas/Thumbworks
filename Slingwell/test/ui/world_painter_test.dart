import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/trail.dart';
import 'package:slingwell/ui/world_painter.dart';

WorldPainter _painter(
  World world, {
  double focusY = 0,
  Trail? trail,
  List<Flash> flashes = const [],
}) =>
    WorldPainter(
      world: world,
      focusY: focusY,
      trail: trail ?? (Trail()..add(world.craft)),
      flashes: flashes,
    );

/// Draw into nothing, which is enough to run every line of the painter.
void _draw(WorldPainter painter, ui.Size size) {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

void main() {
  group('the painter is asked to repaint', () {
    test('when the world has taken a step', () {
      final world = World.newRun(seed: 3);
      final stepped = world.step();
      expect(_painter(stepped).shouldRepaint(_painter(world)), isTrue);
    });

    test('when the camera has moved', () {
      final world = World.newRun(seed: 3);
      expect(
        _painter(world, focusY: 1).shouldRepaint(_painter(world)),
        isTrue,
      );
    });

    test('when the trail has grown', () {
      final world = World.newRun(seed: 3);
      final trail = Trail()..add(world.craft);
      final before = _painter(world, trail: trail);
      trail.add(const Vec(1, 1));
      expect(_painter(world, trail: trail).shouldRepaint(before), isTrue);
    });

    test('while a flash is fading', () {
      final world = World.newRun(seed: 3);
      const at = Vec(0, 0);
      final trail = Trail()..add(world.craft);
      final before = _painter(
        world,
        trail: trail,
        flashes: const [Flash(at: at, age: 0.0, kind: FlashKind.released)],
      );
      final after = _painter(
        world,
        trail: trail,
        flashes: const [Flash(at: at, age: 0.1, kind: FlashKind.released)],
      );
      expect(after.shouldRepaint(before), isTrue);
    });
  });

  group('the painter is not asked to repaint', () {
    test('when nothing about the run has changed', () {
      final world = World.newRun(seed: 3);
      final trail = Trail()..add(world.craft);
      expect(
        _painter(world, trail: trail)
            .shouldRepaint(_painter(world, trail: trail)),
        isFalse,
      );
    });

    test('when a step happened to a run that was already over', () {
      // A finished world hands back itself, so the screen it is already
      // showing is still right.
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 20000 && !world.isOver; i++) {
        world = world.step(tapped: world.isHeld);
      }
      expect(world.isOver, isTrue);
      final trail = Trail()..add(world.craft);
      expect(
        _painter(world.step(), trail: trail)
            .shouldRepaint(_painter(world, trail: trail)),
        isFalse,
      );
    });
  });

  group('drawing a run', () {
    const sizes = [ui.Size(320, 568), ui.Size(390, 844), ui.Size(412, 915)];

    test('works at every phone size, held and flying and finished', () {
      final loop = GameLoop(seed: 3);
      final states = <World>[loop.world];

      loop.advance(const Duration(milliseconds: 100));
      loop.tap();
      loop.advance(const Duration(milliseconds: 200));
      states.add(loop.world);
      expect(loop.world.isHeld, isFalse, reason: 'wanted one in flight');

      for (var i = 0; i < 2000 && !loop.world.isOver; i++) {
        if (loop.world.isHeld) loop.tap();
        loop.advance(const Duration(milliseconds: 16));
      }
      states.add(loop.world);
      expect(loop.world.isOver, isTrue);

      for (final size in sizes) {
        for (final world in states) {
          _draw(
            _painter(
              world,
              focusY: world.cameraY,
              trail: loop.trail,
              flashes: loop.flashes,
            ),
            size,
          );
        }
      }
    });

    test('works far up the world, where the numbers are large', () {
      var world = World.newRun(seed: 3);
      for (var i = 0; i < 4000 && !world.isOver; i++) {
        world = world.step();
      }
      _draw(
        _painter(world, focusY: world.cameraY),
        const ui.Size(390, 844),
      );
    });

    test('works with no trail at all', () {
      final world = World.newRun(seed: 3);
      _draw(_painter(world, trail: Trail()), const ui.Size(390, 844));
    });

    test('draws something rather than an empty screen', () async {
      final world = World.newRun(seed: 3);
      final recorder = ui.PictureRecorder();
      _painter(world, focusY: world.cameraY)
          .paint(Canvas(recorder), const ui.Size(390, 844));
      final picture = recorder.endRecording();
      final image = await picture.toImage(390, 844);
      final bytes = await image.toByteData();
      picture.dispose();

      // The craft is the brightest thing on screen by a distance, so a frame
      // with nothing near white in it is a frame that lost the game.
      var brightest = 0;
      for (var i = 0; i < bytes!.lengthInBytes; i += 4) {
        final red = bytes.getUint8(i);
        if (red > brightest) brightest = red;
      }
      image.dispose();
      expect(brightest, greaterThan(200));
    });
  });
}
