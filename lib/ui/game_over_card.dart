import 'package:flutter/material.dart';

import '../best_run.dart';
import '../sim/world.dart';
import 'chrome.dart';
import 'palette.dart';

/// The end of a run: what it was worth, what there is to beat, and a way
/// straight back in.
///
/// Going again is one tap and no menu. A player who has just lost a run wants
/// the next one, and anything between the two is a reason to put the phone
/// down.
class GameOverCard extends StatelessWidget {
  const GameOverCard({
    super.key,
    required this.world,
    required this.best,
    required this.beatBest,
    required this.reveal,
    required this.onAgain,
  });

  final World world;
  final BestRun best;

  /// Whether this run took the record. Worked out before it was saved, since
  /// saving it is what stops it being true.
  final bool beatBest;

  /// Nought as the run ends, one once the card has arrived.
  final Animation<double> reveal;

  final VoidCallback onAgain;

  static const _endings = {
    Ending.adrift: ('Adrift', 'Nothing caught you.'),
    Ending.crashed: ('Crashed', 'Straight into the core.'),
    Ending.none: ('Run over', ''),
  };

  @override
  Widget build(BuildContext context) {
    final (headline, note) = _endings[world.ending]!;

    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) => IgnorePointer(
        // Nothing here can be hit until the card has finished arriving. The
        // player was tapping to fly a moment ago, and a tap meant for the run
        // must not spend itself on a button that appeared under their thumb.
        ignoring: reveal.value < 1,
        child: Opacity(
          opacity: reveal.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - reveal.value)),
            child: child,
          ),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAgain,
        child: Scrim(
          child: SafeArea(
            // Centred, and scrollable if it cannot be: this is the tallest
            // thing the game draws, and a small screen with large system text
            // must show the button rather than an overflow stripe.
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headline,
                      style: TextStyle(
                        color: world.ending == Ending.crashed
                            ? Palette.wellDanger
                            : Palette.wall,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(note, style: noteStyle),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Readout(
                          value: '${world.score}',
                          label: 'wells',
                          color: Palette.craft,
                          size: 64,
                          align: CrossAxisAlignment.center,
                        ),
                        const SizedBox(width: 44),
                        Readout(
                          value: '${world.cameraY.round()}',
                          label: 'metres up',
                          color: Palette.well,
                          size: 40,
                          align: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (beatBest)
                      const Text(
                        'New best',
                        style: TextStyle(
                          color: Palette.craftHot,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      )
                    else
                      Text(bestLine(best), style: labelStyle),
                    const SizedBox(height: 10),
                    Text('this run was seed ${world.seed}', style: labelStyle),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: onAgain,
                      child: const Text('Go again'),
                    ),
                    const SizedBox(height: 12),
                    const Text('or tap anywhere', style: labelStyle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
