import 'package:flutter/material.dart';

import '../best.dart';
import '../forme/chases.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a forme.
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
                'Chasegarth',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A chase of loose type with one cell empty. Slide the letters '
                'about until the line reads right, in the fewest slides there '
                'are.',
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
              for (var i = 0; i < Formes.count; i++) ...[
                _Pick(
                  number: i,
                  forme: Formes.at(i),
                  slides: best?.slidesFor(Formes.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Formes.count} formes'
                    : '$done of ${Formes.count} locked',
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
              'Half of all arrangements can never be solved',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Count the pairs of letters that are out of order and watch what '
              'a slide does to the count: there is an odd and even to it that '
              'no slide ever changes. Half of all the ways type can stand in a '
              'chase have the wrong one, and no amount of sliding will ever '
              'bring them right. One forme here is like that on purpose, and '
              'it says so on its label.',
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
    required this.forme,
    required this.slides,
    required this.onPlay,
  });

  final int number;
  final Forme forme;

  /// The fewest slides this forme has been locked in, or null.
  final int? slides;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = slides != null;
    final tight = slides == forme.fewest;
    final chase = forme.chase;

    return Semantics(
      button: true,
      label: '${forme.name}, ${chase.reading}',
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
                      forme.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      forme.dropped
                          ? '${chase.reading} · cannot be done as it stands'
                          : '${chase.reading} · '
                              '${chase.wide} by ${chase.tall} · '
                              '${forme.fewest} slides',
                      style: TextStyle(
                        color: forme.dropped ? Palette.bad : Palette.inkDim,
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
                    done ? '$slides' : '-',
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
                    'slides',
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
