import 'package:flutter/material.dart';

import '../best.dart';
import '../board/puzzles.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a puzzle.
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
                'Rookvale',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Every move takes a piece. Leave one standing.',
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
              for (var i = 0; i < Puzzles.count; i++) ...[
                _Pick(
                  number: i,
                  puzzle: Puzzles.at(i),
                  standing: best?.standingOn(Puzzles.at(i).name) ?? 0,
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Puzzles.count} puzzles'
                    : '$done of ${Puzzles.count} done',
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
          border: Border.all(color: Palette.light, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Exactly one way through, every time',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.picked,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not one that was found: one that is all there is. Every board '
              'here has had its whole tree walked, and any with two ways '
              'through was thrown away. So every capture is forced by '
              'something, and there is always a reason to find.',
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
    required this.puzzle,
    required this.standing,
    required this.onPlay,
  });

  final int number;
  final Puzzle puzzle;

  /// Nought for not yet, one for done, two for done unaided.
  final int standing;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${puzzle.name}, ${puzzle.takes} captures',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.board,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: standing > 1 ? Palette.good : Palette.light,
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
                      puzzle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${puzzle.board.count} pieces · '
                      '${puzzle.takes} captures',
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                standing > 1
                    ? Icons.verified_rounded
                    : standing > 0
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                size: 20,
                color: standing > 1
                    ? Palette.good
                    : standing > 0
                        ? Palette.inkDim
                        : Palette.light,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
