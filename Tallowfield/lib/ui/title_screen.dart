import 'package:flutter/material.dart';

import '../best.dart';
import '../garden/evenings.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the evenings to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.dusk,
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
                'Tallowfield',
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
                  'Three hedges keep their tallies. Read them, and name '
                  'the lantern the draught changed.',
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
                  itemCount: Evenings.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _EveningRow(
                    number: number,
                    slips: best?.slipsFor(Evenings.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _EveningRow extends StatelessWidget {
  const _EveningRow({
    required this.number,
    required this.slips,
    required this.onPlay,
  });

  final int number;

  /// The cleanest this evening has been read, or null.
  final int? slips;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final evening = Evenings.at(number);
    final read = slips;
    final doubled = evening.snuffed.length > 1;

    return Semantics(
      button: true,
      label: evening.name,
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.wall,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: read != null ? Palette.good : Palette.line,
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
                        evening.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doubled
                            ? 'two lanterns changed: the tallies will be '
                                'wrong, and that is the lesson'
                            : evening.snuffed.isEmpty
                                ? 'perhaps nothing happened at all'
                                : 'one lantern changed, somewhere',
                        style: TextStyle(
                          color:
                              doubled ? Palette.complaint : Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (read != null)
                  Text(
                    read == 0 ? 'read clean' : 'read, $read against',
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
