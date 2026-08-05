import 'package:flutter/material.dart';

import '../sim/world.dart';
import 'palette.dart';
import 'trail.dart';
import 'world_painter.dart';

/// The mark: a craft swinging round a well, with the trail behind it.
///
/// It is not a drawing of the game — it is a run. The world is started, let
/// go at the right moment and stepped on through the same simulation the game
/// uses, and drawn by the same painter, so the arc in the logo is an arc the
/// physics really produced.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onSky = true});

  /// Whether to draw the sky behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onSky;

  /// How many steps to run before letting go, and how many after. Held long
  /// enough to have gone round, let go, and climbed away.
  static const _held = 26;
  static const _after = 34;

  /// A run, part way through, with what it has flown behind it.
  static (World, Trail) get run {
    var world = World.newRun(seed: 7);
    final trail = Trail();

    for (var step = 0; step < _held + _after; step++) {
      world = world.step(tapped: step == _held);
      if (step % 2 == 0) trail.add(world.craft);
    }
    return (world, trail);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;
          final (world, trail) = run;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onSky)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.skyBottom,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                // Drawn into a canvas twice the width and cropped to the
                // middle of it. The camera fits the playfield to whatever
                // glass it is given, so the way to look closer is to hand it
                // a bigger piece of glass and show half of it: seven metres
                // across a logo rather than fourteen.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(side * 0.16),
                    child: OverflowBox(
                      minWidth: side * 2,
                      maxWidth: side * 2,
                      minHeight: side * 2,
                      maxHeight: side * 2,
                      child: CustomPaint(
                        size: Size(side * 2, side * 2),
                        painter: WorldPainter(
                          world: world,
                          focusY: world.craft.y - 0.4,
                          trail: trail,
                          flashes: const [],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
