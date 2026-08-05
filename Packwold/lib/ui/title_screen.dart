import 'package:flutter/material.dart';

import '../best.dart';
import '../fit/boxes.dart';
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
                'Packwold',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Twelve shapes of five squares. Fit the ones you are given '
                'into the ground you are given.',
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
                  hints: best?.hintsFor(Puzzles.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Puzzles.count} puzzles'
                    : '$done of ${Puzzles.count} packed',
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
          color: Palette.chalk,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.furrow, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Every box has exactly one packing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not one that was found — the only one there is. Each box was '
              'handed to a search that walks every way of covering it, and '
              'any box with a second way was thrown out. So nothing here is '
              'guesswork: whatever you work out is the answer.',
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
    required this.hints,
    required this.onPlay,
  });

  final int number;
  final Puzzle puzzle;

  /// The fewest hints this puzzle has been packed with, or null.
  final int? hints;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = hints != null;
    final alone = hints == 0;

    return Semantics(
      button: true,
      label: '${puzzle.name}, ${puzzle.pieces} pieces',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.chalk,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alone ? Palette.good : Palette.furrow,
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
                      '${puzzle.pieces} pieces · '
                      '${puzzle.pieces * 5} squares',
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
                    done ? 'packed' : '—',
                    style: TextStyle(
                      color: alone
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (done)
                    Text(
                      alone ? 'on your own' : '$hints looked at',
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
