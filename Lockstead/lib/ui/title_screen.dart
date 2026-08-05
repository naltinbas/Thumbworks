import 'package:flutter/material.dart';

import '../best.dart';
import '../lock/boards.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a lock.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final opened = best?.opened ?? 0;

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
                'Lockstead',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find the code. A peg right where it is, or right somewhere '
                'else.',
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
              for (var i = 0; i < Boards.count; i++) ...[
                _Pick(
                  board: Boards.at(i),
                  guesses: best?.guessesFor(Boards.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                opened == 0
                    ? '${Boards.count} locks'
                    : '$opened of ${Boards.count} opened',
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
          color: Palette.bench,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.groove, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'The number of guesses is the promise',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.brass,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Five is not a difficulty setting. Every one of the 1296 codes '
              'in the first lock can be found in five guesses, and a test '
              'walks the whole tree to say so. You get exactly that many, '
              'because that many is always enough.',
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
    required this.board,
    required this.guesses,
    required this.onPlay,
  });

  final Board board;

  /// The fewest guesses this lock has been opened in, or null.
  final int? guesses;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final opened = guesses != null;

    return Semantics(
      button: true,
      label: '${board.name}, ${board.about}',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.bench,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: opened ? Palette.brass : Palette.groove,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${board.about} · ${board.codes} codes · '
                      'always ${board.inside}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    opened ? '$guesses' : '-',
                    style: TextStyle(
                      color: opened ? Palette.brass : Palette.inkDim,
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
