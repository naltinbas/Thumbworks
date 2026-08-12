import 'package:flutter/material.dart';

import '../best.dart';
import '../score/rings.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the rings to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
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
                'Scoreham',
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
                  'Walk the tally round the ring of scores and find '
                  'the starts that never touch the ground.',
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
                  itemCount: Rings.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _RingRow(
                    number: number,
                    tries: best?.triesFor(Rings.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _RingRow extends StatelessWidget {
  const _RingRow({
    required this.number,
    required this.tries,
    required this.onPlay,
  });

  final int number;

  /// The fewest tries this ring has been settled in, or null.
  final int? tries;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ring = Rings.at(number);
    final done = tries;
    final notches = ring.marks.where((mark) => mark == 1).length;
    final wipes = ring.marks.length - notches;

    return Semantics(
      button: true,
      label: '${ring.name}, ${ring.marks.length} marks',
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
                        ring.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ring.winnable
                            ? '$notches notches, $wipes wipes: '
                                '${ring.task}'
                            : '$notches notches, $wipes wipes: '
                                '${ring.task}, and there is none',
                        style: TextStyle(
                          color: ring.winnable
                              ? Palette.inkDim
                              : Palette.bad,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done != null)
                  Text(
                    'found in $done',
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
