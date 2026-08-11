import 'package:flutter/material.dart';

import '../best.dart';
import '../hoard/hoards.dart';
import '../hoard/rules.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the hoards to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.wood,
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
                'Filberthow',
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
                  'Take up to twice the last take. The last hazelnut wins '
                  'the hoard.',
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
                  itemCount: Hoards.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _HoardRow(
                    number: number,
                    askings: best?.askingsFor(Hoards.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _HoardRow extends StatelessWidget {
  const _HoardRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this hoard has been won with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final hoard = Hoards.at(number);
    final won = askings;

    return Semantics(
      button: true,
      label: '${hoard.name}, ${hoard.nuts} nuts',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.log,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: won != null ? Palette.good : Palette.line,
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
                        hoard.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hoard.winnable
                            ? '${hoard.nuts} nuts: '
                                '${Rules.split(hoard.nuts).join(" + ")}'
                            : '${hoard.nuts} nuts, one whole cluster: the '
                                'opener is lost',
                        style: TextStyle(
                          color: hoard.winnable
                              ? Palette.inkDim
                              : Palette.shell,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (won != null)
                  Text(
                    won == 0 ? 'won unasked' : 'won, asked $won',
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
