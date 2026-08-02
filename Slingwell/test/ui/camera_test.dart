import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/camera.dart';
import 'package:slingwell/ui/game_screen.dart';
import 'package:slingwell/ui/playfield.dart';

/// The narrowest phone anyone is still holding, a tall one, and a tablet,
/// which nothing stops a player installing a phone game on.
const _small = Size(320, 568);
const _tall = Size(412, 915);
const _tablet = Size(768, 1024);

void main() {
  group('the camera', () {
    test('draws up the world as up the screen', () {
      final camera = Camera.forSize(_tall, 0);
      expect(
        camera.toScreen(const Vec(0, 1)).dy,
        lessThan(camera.toScreen(const Vec(0, 0)).dy),
      );
    });

    test('puts the height it is following below the middle', () {
      // What is above the craft is where the run is going, so it gets the
      // bigger half of the screen.
      final camera = Camera.forSize(_tall, 40);
      final line = camera.toScreen(const Vec(0, 40)).dy;
      expect(line, greaterThan(_tall.height / 2));
      expect(line, lessThan(_tall.height * 0.8));
    });

    test('fits both walls on the narrowest phone', () {
      final camera = Camera.forSize(_small, 0);
      for (final side in [-1.0, 1.0]) {
        final x = camera.toScreen(Vec(side * Playfield.edgeX, 0)).dx;
        expect(x, greaterThan(0));
        expect(x, lessThan(_small.width));
      }
    });

    test('leaves room below the focus for the fall that ends a run', () {
      // A craft dropping out of the run should be watched dropping, not
      // vanish off the bottom a moment before the game says so. The whole of
      // the fall, not just the line it ends on: the step it dies on carries
      // it past the line and the nose of the craft is drawn ahead of it.
      for (final size in [_small, _tall, _tablet]) {
        final camera = Camera.forSize(size, 0);
        final dead = camera.toScreen(const Vec(0, -Playfield.fallBehind)).dy;
        expect(dead, lessThan(size.height), reason: '$size');
        final lowest =
            camera.toScreen(const Vec(0, -Camera.viewBelowMetres)).dy;
        expect(lowest, lessThanOrEqualTo(size.height), reason: '$size');
      }
    });

    test('gives up width rather than the fall on a screen too wide for it', () {
      // A tablet is wide enough that a metre off the width would put the
      // bottom of the playfield below the bottom of the glass.
      final camera = Camera.forSize(_tablet, 0);
      expect(camera.pxPerMetre, lessThan(_tablet.width / Camera.viewWidthMetres));
      // The walls stay on screen with sky outside them rather than being cut
      // off, which is the point of shrinking rather than cropping.
      final wall = camera.toScreen(const Vec(Playfield.edgeX, 0)).dx;
      expect(wall, lessThan(_tablet.width));
      expect(_tablet.width - wall, greaterThan(0));
    });

    test('leaves room above the focus for the title to lift the world into',
        () {
      // The title raises the world so the craft swings clear of the words.
      // The craft rides two metres out from the well it is on, so the lift
      // plus the tether has to stay on the glass whatever shape it is.
      const needed = GameScreen.titleLift + 2 + 1;
      for (final size in [_small, _tall, _tablet, const Size(600, 600)]) {
        final camera = Camera.forSize(size, 0);
        expect(
          camera.toScreen(Vec(0, needed)).dy,
          greaterThanOrEqualTo(0),
          reason: '$size',
        );
      }
    });

    test('leaves a phone-shaped screen its full width', () {
      for (final size in [_small, _tall]) {
        expect(
          Camera.forSize(size, 0).pxPerMetre,
          closeTo(size.width / Camera.viewWidthMetres, 0.5),
          reason: '$size',
        );
      }
    });

    test('uses the same scale across and up', () {
      final camera = Camera.forSize(_tall, 0);
      final across = camera.toScreen(const Vec(1, 0)).dx -
          camera.toScreen(const Vec(0, 0)).dx;
      final up = camera.toScreen(const Vec(0, 0)).dy -
          camera.toScreen(const Vec(0, 1)).dy;
      expect(across, closeTo(camera.px(1), 1e-9));
      expect(up, closeTo(camera.px(1), 1e-9));
    });

    test('shows more of the world on a bigger phone, not more of a metre', () {
      final small = Camera.forSize(_small, 0);
      final tall = Camera.forSize(_tall, 0);
      expect(tall.topY - tall.bottomY, greaterThan(small.topY - small.bottomY));
    });

    test('knows which heights are on the screen', () {
      final camera = Camera.forSize(_tall, 100);
      expect(camera.toScreen(Vec(0, camera.topY)).dy, closeTo(0, 1e-9));
      expect(
        camera.toScreen(Vec(0, camera.bottomY)).dy,
        closeTo(_tall.height, 1e-9),
      );
    });

    test('looks somewhere else without changing how big a metre is', () {
      final camera = Camera.forSize(_tall, 100);
      final behind = camera.lookingAt(32);
      expect(behind.pxPerMetre, camera.pxPerMetre);
      expect(behind.focusY, 32);
    });
  });
}
