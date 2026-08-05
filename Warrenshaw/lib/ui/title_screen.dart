import 'package:flutter/material.dart';

import '../best.dart';
import '../chase/maps.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a map.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final done = best?.done ?? 0;

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
                'Warrenshaw',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You move along a path, then it does. Corner it.',
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
              for (var i = 0; i < Warrens.count; i++) ...[
                _Pick(
                  number: i,
                  warren: Warrens.at(i),
                  moves: best?.movesFor(Warrens.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Warrens.count} maps'
                    : '$done of ${Warrens.count} won',
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
          color: Palette.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.hedge, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'It runs as well as anything could',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Every position of every chase is worked out before you start, '
              'so the runner always takes the move that keeps it out of reach '
              'the longest. The number on a map is the fewest moves that can '
              'beat it — and the last map cannot be won by anybody, which is '
              'not a difficulty setting but a theorem.',
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
    required this.number,
    required this.warren,
    required this.moves,
    required this.onPlay,
  });

  final int number;
  final Warren warren;

  /// The fewest moves this map has been won in, or null.
  final int? moves;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = moves != null;
    final perfect = warren.par != null && moves == warren.par;

    return Semantics(
      button: true,
      label: '${warren.name}, ${warren.places.length} places',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: perfect ? Palette.good : Palette.hedge,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '${number + 1}',
                  style: const TextStyle(
                    color: Palette.inkDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warren.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      warren.hopeless
                          ? '${warren.places.length} places · '
                              'nobody can win this one'
                          : '${warren.places.length} places · '
                              '${warren.par} moves',
                      style: TextStyle(
                        color: warren.hopeless
                            ? Palette.bad
                            : Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    done ? '$moves' : '—',
                    style: TextStyle(
                      color: perfect
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'your best',
                    style: TextStyle(color: Palette.inkDim, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
