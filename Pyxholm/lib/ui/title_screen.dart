import 'package:flutter/material.dart';

import '../assay/boxes.dart';
import '../assay/pyx.dart';
import '../best.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a box.
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
                'Pyxholm',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'One coin in the box is the wrong weight. Find it, and say '
                'which way, on a balance and nothing else.',
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
              for (var i = 0; i < Boxes.count; i++) ...[
                _Pick(
                  number: i,
                  pyx: Boxes.at(i),
                  weighings: best?.weighingsFor(Boxes.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Boxes.count} boxes'
                    : '$done of ${Boxes.count} settled',
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
              'Three answers a weighing, and no more',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Left down, right down, or level. So two weighings tell nine '
              'things apart at the very most and three tell twenty seven, and '
              'a dozen coins that might each be heavy or light is twenty four '
              'things. That is where the number on each box comes from, and '
              'the beam here answers as badly as it truthfully can, so nothing '
              'is ever settled by luck.',
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
    required this.pyx,
    required this.weighings,
    required this.onPlay,
  });

  final int number;
  final Pyx pyx;

  /// The fewest weighings this box has been settled in, or null.
  final int? weighings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = weighings != null;
    final tight = weighings == pyx.fewest;

    return Semantics(
      button: true,
      label: '${pyx.name}, ${pyx.coins} coins',
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
                      pyx.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${pyx.coins} coins · '
                      '${pyx.knownLight ? 'the wrong one is light' : 'either '
                          'way wrong'} · '
                      '${pyx.verdicts} to tell apart',
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
                    done ? '$weighings' : '${pyx.fewest}',
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
                  Text(
                    done ? 'weighings' : 'to beat',
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
