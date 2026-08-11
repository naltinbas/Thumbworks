import 'package:flutter/material.dart';

import '../best.dart';
import '../ring/watches.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the watches to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.marsh,
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
                'Ringmarsh',
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
                  'Turn the lanterns until every run of the watch '
                  'round the ring spells a different word.',
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
                  itemCount: Watches.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _WatchRow(
                    number: number,
                    askings: best?.askingsFor(Watches.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _WatchRow extends StatelessWidget {
  const _WatchRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this watch has been set with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final watch = Watches.at(number);
    final done = askings;

    return Semantics(
      button: true,
      label: '${watch.name}, ${watch.length} lanterns',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: done != null ? Palette.good : Palette.line,
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
                        watch.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        watch.winnable
                            ? '${watch.length} lanterns, words of '
                                '${watch.span}, ${watch.ways} '
                                'ring${watch.ways == 1 ? '' : 's'} '
                                'set${watch.ways == 1 ? 's' : ''} it'
                            : '${watch.length} lanterns for '
                                '${watch.words} words: no ring sets '
                                'it',
                        style: TextStyle(
                          color:
                              watch.winnable ? Palette.inkDim : Palette.bad,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done != null)
                  Text(
                    done == 0 ? 'set unasked' : 'set, asked $done',
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
