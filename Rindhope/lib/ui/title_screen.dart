import 'package:flutter/material.dart';

import '../best.dart';
import '../cheese/blocks.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the blocks to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.larder,
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
                'Rindhope',
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
                  'Bite the cheese and leave the grey mouse the mouldy '
                  'crumb.',
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
                  itemCount: Blocks.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _BlockRow(
                    number: number,
                    bites: best?.bitesFor(Blocks.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.number,
    required this.bites,
    required this.onPlay,
  });

  final int number;

  /// The fewest bites this block has been won in, or null.
  final int? bites;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final block = Blocks.at(number);
    final won = bites;
    final atPar = won != null && won <= (block.fewest ?? 0);

    return Semantics(
      button: true,
      label: '${block.name}, ${block.width} by ${block.height}',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.shelf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: atPar ? Palette.good : Palette.line,
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
                        block.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        block.hopeless
                            ? '${block.width} by ${block.height}, the grey '
                                'mouse first: it cannot be beaten'
                            : '${block.width} by ${block.height} crumbs, '
                                'the win in ${block.fewest}',
                        style: TextStyle(
                          color: block.hopeless
                              ? Palette.mould
                              : Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (won != null)
                  Text(
                    'won in $won',
                    style: TextStyle(
                      color: atPar ? Palette.good : Palette.inkDim,
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
