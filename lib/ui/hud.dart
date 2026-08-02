import 'package:flutter/widgets.dart';

import 'chrome.dart';
import 'game_loop.dart';
import 'palette.dart';

/// What the player needs to know while a run is going: how many wells they
/// have taken, how high they have got, and what there is to beat.
///
/// It reads the loop directly rather than being handed numbers, so it redraws
/// on the frames the world moved on and no others. It never takes a tap: the
/// whole screen belongs to the run underneath.
class Hud extends StatelessWidget {
  const Hud({super.key, required this.loop, required this.best});

  final GameLoop loop;

  /// Wells in the best run so far, or zero if there has not been one.
  final int best;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
          child: AnimatedBuilder(
            animation: loop,
            builder: (context, _) {
              final world = loop.world;
              // The high point of the run rather than where the craft is now,
              // so a fall does not wind the number back down and rob the
              // player of the height they earned.
              final metres = world.cameraY.round();
              final ahead = best > 0 && world.score > best;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Readout(
                        value: '${world.score}',
                        label: 'wells',
                        color: Palette.craft,
                        size: 52,
                      ),
                      if (ahead)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'ahead of your best',
                            style: TextStyle(
                              color: Palette.craft,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Readout(
                        value: '$metres',
                        label: 'metres up',
                        color: Palette.well,
                        size: 34,
                        align: CrossAxisAlignment.end,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        best > 0 ? 'best $best' : 'no best yet',
                        style: labelStyle,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
