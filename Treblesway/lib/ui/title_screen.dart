import 'package:flutter/material.dart';

import '../best.dart';
import '../ring/peals.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a tower.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final done = best?.done ?? 0;
    final ringable = Peals.all.where((peal) => !peal.hopeless).length;

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
                'Treblesway',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ring the bells through every order they can sound in, one '
                'change at a time, repeating none, and bring rounds home at '
                'the end.',
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
              for (var i = 0; i < Peals.count; i++) ...[
                _Pick(
                  number: i,
                  peal: Peals.at(i),
                  hints: best?.hintsFor(Peals.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Peals.count} towers, $ringable of them ringable'
                    : '$done of $ringable rung',
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
          color: Palette.verge,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.line, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'A bell may move one place a change, no more',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'A bell swinging full circle can be checked a little or let go '
              'a little, so between one row and the next it keeps its place '
              'or trades with a neighbour. That rule of the bells themselves '
              'is the whole game, and one tower here has changes so mean '
              'that twenty of the twenty four rows can never sound at all.',
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
    required this.peal,
    required this.hints,
    required this.onPlay,
  });

  final int number;
  final Peal peal;

  /// The fewest askings this peal has been rung with, or null.
  final int? hints;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = hints != null;
    final clean = hints == 0;

    return Semantics(
      button: true,
      label: '${peal.name}, ${peal.tower.bells} bells',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.verge,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done ? Palette.good : Palette.line,
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
                      peal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      peal.hopeless
                          ? '${peal.tower.bells} bells · cannot ring the '
                              '${peal.goalRows}'
                          : '${peal.tower.bells} bells · '
                              '${peal.tower.changes.length} changes · '
                              '${peal.goalRows} rows',
                      style: TextStyle(
                        color: peal.hopeless ? Palette.bad : Palette.inkDim,
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
                    done ? '$hints' : (peal.hopeless ? 'no' : '-'),
                    style: TextStyle(
                      color: clean
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    peal.hopeless ? 'way' : 'askings',
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 11,
                    ),
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
