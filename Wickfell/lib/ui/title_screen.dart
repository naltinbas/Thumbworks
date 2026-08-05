import 'package:flutter/material.dart';

import '../best.dart';
import '../lamps/levels.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a board.
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
                'Wickfell',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Put every lamp out. Each one you touch turns its neighbours '
                'too.',
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
              for (var i = 0; i < Levels.count; i++) ...[
                _Pick(
                  number: i,
                  level: Levels.at(i),
                  presses: best?.pressesFor(Levels.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Levels.count} boards'
                    : '$done of ${Levels.count} put out',
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
          color: Palette.hill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.socket, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'The number of presses is the fewest there are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.lit,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Pressing twice undoes it and the order never matters, so a set '
              'of presses is a choice for each lamp, which makes this a set '
              'of equations rather than a search. Every number here is what '
              'solving them gives, and so is the line that says the moment '
              'you have wandered off it.',
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
    required this.level,
    required this.presses,
    required this.onPlay,
  });

  final int number;
  final Level level;

  /// The fewest presses this board has been put out in, or null.
  final int? presses;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = presses != null;
    final perfect = presses == level.presses;

    return Semantics(
      button: true,
      label: '${level.name}, ${level.presses} presses',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.hill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: perfect ? Palette.good : Palette.socket,
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
                      level.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${level.across}×${level.down} · '
                      '${level.presses} presses',
                      style: const TextStyle(
                        color: Palette.inkDim,
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
                    done ? '$presses' : '-',
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
