import 'package:flutter/material.dart';

import '../best.dart';
import '../hall/halls.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the halls to choose from.
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
                'Wardhall',
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
                  'Post wards at the corners until every flag of '
                  'the floor is lit.',
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
                  itemCount: Halls.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _HallRow(
                    number: number,
                    askings: best?.askingsFor(Halls.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _HallRow extends StatelessWidget {
  const _HallRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this hall has been lit with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final hall = Halls.at(number);
    final done = askings;

    return Semantics(
      button: true,
      label: '${hall.name}, ${hall.corners.length} corners',
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
                        hall.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hall.winnable
                            ? '${hall.corners.length} corners, '
                                '${hall.task}'
                            : '${hall.corners.length} corners, '
                                '${hall.task}: no watch ever has',
                        style: TextStyle(
                          color: hall.winnable
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
                    'lit, asking $done',
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
