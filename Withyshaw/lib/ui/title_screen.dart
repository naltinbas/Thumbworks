import 'package:flutter/material.dart';

import '../best.dart';
import '../hedge/hedges.dart';
import '../hedge/rules.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the hedges to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.lane,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: SizedBox(width: 140, height: 132, child: Mark()),
              ),
              const SizedBox(height: 12),
              const Text(
                'Withyshaw',
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
                  'Cut your withies, never theirs. Whoever cannot cut has '
                  'lost the hedge.',
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
                  itemCount: Hedges.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _HedgeRow(
                    number: number,
                    askings: best?.askingsFor(Hedges.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _HedgeRow extends StatelessWidget {
  const _HedgeRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this hedge has been held with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final hedge = Hedges.at(number);
    final held = askings;
    final worth = Rules.worthOfHedge(hedge.stalks);

    return Semantics(
      button: true,
      label: '${hedge.name}, worth ${worth.said}',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.gate,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: held != null ? Palette.good : Palette.line,
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
                        hedge.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hedge.winnable
                            ? '${hedge.stalks.length} '
                                'stalk${hedge.stalks.length == 1 ? '' : 's'}'
                                ', worth ${worth.said}'
                            : 'worth exactly nought: whoever cuts first '
                                'loses, and that is you',
                        style: TextStyle(
                          color: hedge.winnable
                              ? Palette.inkDim
                              : Palette.theirs,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (held != null)
                  Text(
                    held == 0 ? 'held unasked' : 'held, asked $held',
                    style: const TextStyle(
                      color: Palette.good,
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
