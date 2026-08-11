import 'package:flutter/material.dart';

import '../best.dart';
import '../fold/folds.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the folds to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
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
                'Foldbury',
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
                  'Post the fewest shepherds that leave no lane unwatched.',
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
                  itemCount: Folds.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _FoldRow(
                    number: number,
                    shepherds: best?.shepherdsFor(Folds.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FoldRow extends StatelessWidget {
  const _FoldRow({
    required this.number,
    required this.shepherds,
    required this.onPlay,
  });

  final int number;

  /// The fewest this fold has been watched with, or null when it never has.
  final int? shepherds;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final fold = Folds.at(number);
    final watched = shepherds;
    final fewest = watched != null && watched <= fold.fewest;

    return Semantics(
      button: true,
      label: '${fold.name}, ${fold.count} gates, ${fold.many} lanes',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.verge,
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
                        fold.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fold.count} gates, ${fold.many} lanes, '
                        '${fold.fewest} shepherds',
                        style: const TextStyle(
                          color: Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (watched != null)
                  Text(
                    'watched on $watched',
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
