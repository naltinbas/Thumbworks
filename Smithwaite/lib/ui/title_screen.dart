import 'package:flutter/material.dart';

import '../best.dart';
import '../forge/puzzles.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the puzzles to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.soot,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: SizedBox(width: 132, height: 132, child: Mark()),
              ),
              const SizedBox(height: 12),
              const Text(
                'Smithwaite',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  'Work the rings off the smith\'s bar in the fewest moves '
                  'there are.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Palette.inkDim,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
                  itemCount: Puzzles.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _PuzzleRow(
                    number: number,
                    moves: best?.movesFor(Puzzles.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _PuzzleRow extends StatelessWidget {
  const _PuzzleRow({
    required this.number,
    required this.moves,
    required this.onPlay,
  });

  final int number;

  /// The fewest moves this puzzle has been freed on, or null.
  final int? moves;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final puzzle = Puzzles.at(number);
    final freed = moves;
    final fewest = freed != null && freed <= puzzle.fewest;

    return Semantics(
      button: true,
      label: '${puzzle.name}, ${puzzle.rings} rings',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.bench,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: fewest ? Palette.good : Palette.line,
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
                        puzzle.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        puzzle.laid == null
                            ? '${puzzle.rings} rings, fewest ${puzzle.fewest}'
                            : '${puzzle.rings} rings, one on, fewest '
                                '${puzzle.fewest}',
                        style: const TextStyle(
                          color: Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (freed != null)
                  Text(
                    'freed on $freed',
                    style: TextStyle(
                      color: fewest ? Palette.good : Palette.inkDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: Palette.inkDim,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
