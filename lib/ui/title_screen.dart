import 'package:flutter/material.dart';

import '../best.dart';
import '../game/plots.dart';
import '../game/reason.dart';
import 'hud.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a plot.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final cleared = best?.cleared ?? 0;

    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(width: 104, height: 104, child: Mark()),
              const SizedBox(height: 20),
              const Text(
                'Cinderplot',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A minefield you never have to guess at.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const _Note(),
              const SizedBox(height: 20),
              for (var i = 0; i < Plots.count; i++) ...[
                _Pick(
                  plot: Plots.at(i),
                  seconds: best?.secondsFor(Plots.at(i).name),
                  cleared: best?.clearedOn(Plots.at(i).name) ?? 0,
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                cleared == 0
                    ? '${Plots.count} plots'
                    : '$cleared cleared',
                style: const TextStyle(color: Palette.inkDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one thing worth saying about the game before somebody plays it.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Palette.plot,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.furrow, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Every board can be finished by working it out',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ember,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not usually. Always. A board is laid out, played through by '
              'reasoning alone, and thrown away if the reasoning ever runs '
              'out. What you get is what survived that.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.inkDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.plot,
    required this.seconds,
    required this.cleared,
    required this.onPlay,
  });

  final Plot plot;

  /// The quickest clear of this plot, or null.
  final int? seconds;
  final int cleared;

  final VoidCallback onPlay;

  static const _mark = <Rule, IconData>{
    Rule.counted: Icons.looks_one_rounded,
    Rule.subset: Icons.looks_two_rounded,
    Rule.whole: Icons.grid_view_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final played = cleared > 0;

    return Semantics(
      button: true,
      label: '${plot.name}, ${plot.about}',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.plot,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: played ? Palette.ember : Palette.furrow,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _mark[plot.needs],
                size: 22,
                color: played ? Palette.ember : Palette.inkDim,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${plot.about} · ${plot.across}×${plot.down}, '
                      '${plot.mines} mines',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                seconds == null ? '' : Ledger.clock(seconds!),
                style: const TextStyle(
                  color: Palette.ember,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
