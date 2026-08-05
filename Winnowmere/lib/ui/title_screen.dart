import 'package:flutter/material.dart';

import '../best.dart';
import '../sift/puzzles.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a works.
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
                'Winnowmere',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Put comparators on the lines until every row that can come '
                'down them comes out sorted.',
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
              for (var i = 0; i < Siftings.count; i++) ...[
                _Pick(
                  number: i,
                  sifting: Siftings.at(i),
                  crosses: best?.crossesFor(Siftings.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Siftings.count} puzzles'
                    : '$done of ${Siftings.count} sorted',
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
          border: Border.all(color: Palette.rail, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'The number is the fewest comparators there are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Nothing here is read out of a book. A walk over every network '
              'there is, counting the ones that leave the same rows behind '
              'once, settles two lines up to seven, and those are the numbers '
              'it comes back with. Whether a network sorts is settled the '
              'same way: every row of noughts and ones, which is all it takes '
              'to know it sorts anything at all.',
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
    required this.sifting,
    required this.crosses,
    required this.onPlay,
  });

  final int number;
  final Sifting sifting;

  /// The fewest comparators this puzzle has been sorted with, or null.
  final int? crosses;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = crosses != null;
    final tight = crosses == sifting.fewest;

    return Semantics(
      button: true,
      label: '${sifting.name}, ${sifting.lines} lines',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.bench,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done ? Palette.good : Palette.rail,
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
                      sifting.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${sifting.lines} lines · '
                      '${sifting.fewest} comparators'
                      '${sifting.given.isEmpty ? '' : ', '
                          '${sifting.given.length} of them given'}',
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
                    done ? '$crosses' : '-',
                    style: TextStyle(
                      color: tight
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'comparators',
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
