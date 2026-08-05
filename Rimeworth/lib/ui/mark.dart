import 'package:flutter/material.dart';

import '../round/parish.dart';
import '../round/parishes.dart';
import '../round/play.dart';
import '../round/runs.dart';
import 'palette.dart';
import 'parishview.dart';

/// The mark: a small parish with most of it salted, part way through a run.
///
/// It is not a drawing of the game. The route is the one the game lays out,
/// driven through the same code a finger goes through, and a test asserts the
/// picture really is a run that has salted every lane it has been down once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the verge behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Parish get parish => Grittings.at(1).parish;

  /// The first run, stopped two lanes short so that the lorry is out in the
  /// middle of the parish with something still to do.
  static Play get part {
    final route = Runs.routes(parish).first;
    var play = Play.of(parish).touch(route.first);
    for (var step = 1; step < route.length - 2; step++) {
      play = play.touch(route[step]);
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onVerge)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.verge,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: ParishView(
                        play: part,
                        pointing: -1,
                        // No names in the mark: at forty eight points they
                        // are a smudge, and the picture is the lanes.
                        labels: const TextStyle(
                          color: Color(0x00000000),
                          fontSize: 0.1,
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
