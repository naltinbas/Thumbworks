import 'package:flutter/material.dart';

import '../best.dart';
import '../griddle/batches.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the batches to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.iron,
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
                'Shroveham',
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
                  'Flip the cakes until they sit in order, in the fewest '
                  'flips there are.',
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
                  itemCount: Batches.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _BatchRow(
                    number: number,
                    flips: best?.flipsFor(Batches.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _BatchRow extends StatelessWidget {
  const _BatchRow({
    required this.number,
    required this.flips,
    required this.onPlay,
  });

  final int number;

  /// The fewest flips this batch has been served on, or null.
  final int? flips;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final batch = Batches.at(number);
    final served = flips;
    final fewest = served != null && served <= batch.fewest;

    return Semantics(
      button: true,
      label: '${batch.name}, ${batch.many} cakes',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.hearth,
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
                        batch.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${batch.many} cakes, fewest ${batch.fewest}',
                        style: const TextStyle(
                          color: Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (served != null)
                  Text(
                    'served on $served',
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
