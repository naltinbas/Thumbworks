import 'package:flutter/material.dart';

import '../best.dart';
import '../ladder/climbs.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a climb.
class TitleScreen extends StatelessWidget {
  const TitleScreen({
    super.key,
    required this.best,
    required this.ready,
    required this.onPlay,
  });

  final Best? best;

  /// Whether the word graph has been worked out yet.
  final bool ready;

  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final climbed = best?.climbed ?? 0;

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
                'Rungwick',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'One word to another, a letter at a time, and every rung a '
                'word.',
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
              for (var i = 0; i < Climbs.count; i++) ...[
                _Pick(
                  climb: Climbs.at(i),
                  rungs: best?.rungsFor(Climbs.at(i).from, Climbs.at(i).to),
                  ready: ready,
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                climbed == 0
                    ? '${Climbs.count} climbs'
                    : '$climbed of ${Climbs.count} climbed',
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
          color: Palette.board,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.rungEdge, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'The number of rungs is the fewest there are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.rope,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not a good score somebody once got. Every four letter word in '
              'the list is walked outwards from the far end of the climb, so '
              'the number is the shortest way there is, and the game can '
              'tell you the moment you step off it.',
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
    required this.climb,
    required this.rungs,
    required this.ready,
    required this.onPlay,
  });

  final Climb climb;

  /// The fewest rungs this climb has been done in, or null.
  final int? rungs;

  final bool ready;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = rungs != null;
    final perfect = rungs == climb.rungs;

    return Semantics(
      button: true,
      label: '${climb.from} to ${climb.to}, ${climb.rungs} rungs',
      child: GestureDetector(
        onTap: ready ? onPlay : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Palette.board,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: perfect ? Palette.good : Palette.rungEdge,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      climb.from,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Palette.inkDim,
                      ),
                    ),
                    Text(
                      climb.to,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    done ? '$rungs' : '${climb.rungs}',
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
                  Text(
                    done ? 'your best' : 'rungs',
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 11,
                    ),
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
