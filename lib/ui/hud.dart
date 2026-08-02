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

  /// How far the system's text setting is followed here.
  ///
  /// The figures are display-sized already, so the largest phone setting would
  /// put a hundred-pixel number over the playfield and run the two corners
  /// into each other on a narrow screen. Everything a player has to read to
  /// understand the game is on the cards, which scale the whole way; this is
  /// the running score over a moving picture, and it stays out of the way.
  static const _maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: _maxTextScale,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: AnimatedBuilder(
              animation: loop,
              builder: (context, _) {
                final world = loop.world;
                // The high point of the run rather than where the craft is
                // now, so a fall does not wind the number back down and rob
                // the player of the height they earned.
                final metres = world.cameraY.round();
                final ahead = best > 0 && world.score > best;

                // Flexible on both corners: a long word at a large setting
                // takes what room is left rather than pushing a stripe across
                // the top of the game.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
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
                    ),
                    Flexible(
                      child: Column(
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
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
