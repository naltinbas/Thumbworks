import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/yards.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the yards to choose from.
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
                'Peckhollow',
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
                  'Turn the pecking arrows of the yard and crown '
                  'the kings the task asks for.',
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
                  itemCount: Yards.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _YardRow(
                    number: number,
                    flips: best?.flipsFor(Yards.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _YardRow extends StatelessWidget {
  const _YardRow({
    required this.number,
    required this.flips,
    required this.onPlay,
  });

  final int number;

  /// The fewest flips this yard's crowning has come in, or null.
  final int? flips;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final yard = Yards.at(number);
    final done = flips;

    return Semantics(
      button: true,
      label: '${yard.name}, ${yard.birds} birds',
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
                        yard.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        yard.winnable
                            ? '${yard.birds} birds, ${yard.task} '
                                'in ${yard.par} '
                                'flip${yard.par == 1 ? '' : 's'}'
                            : '${yard.birds} birds, ${yard.task}: '
                                'no yard ever wears it',
                        style: TextStyle(
                          color: yard.winnable
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
                    'crowned in $done',
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
