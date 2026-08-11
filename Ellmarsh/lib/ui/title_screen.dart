import 'package:flutter/material.dart';

import '../best.dart';
import '../cloth/benches.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the benches to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.shop,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: SizedBox(width: 148, height: 132, child: Mark()),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ellmarsh',
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
                  'Cut lengths of the short bolt from the long one. The '
                  'last cut keeps the bench.',
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
                  itemCount: Benches.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _BenchRow(
                    number: number,
                    askings: best?.askingsFor(Benches.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _BenchRow extends StatelessWidget {
  const _BenchRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this bench has been held with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final bench = Benches.at(number);
    final held = askings;

    return Semantics(
      button: true,
      label: '${bench.name}, ${bench.long} and ${bench.short} ells',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.bench,
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
                        bench.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bench.winnable
                            ? '${bench.long} and ${bench.short} ells'
                            : '${bench.long} and ${bench.short} ells, '
                                'inside the gap: the mercer holds it',
                        style: TextStyle(
                          color: bench.winnable
                              ? Palette.inkDim
                              : Palette.golden,
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
