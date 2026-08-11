import 'package:flutter/material.dart';

import '../best.dart';
import '../shunt/trays.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the trays to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.bench,
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
                'Shuntley',
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
                  'Slide the tiles home through the one gap, fewest '
                  'shunts wearing the crown.',
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
                  itemCount: Trays.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _TrayRow(
                    number: number,
                    shunts: best?.shuntsFor(Trays.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _TrayRow extends StatelessWidget {
  const _TrayRow({
    required this.number,
    required this.shunts,
    required this.onPlay,
  });

  final int number;

  /// The fewest shunts this tray has come home with, or null.
  final int? shunts;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final tray = Trays.at(number);
    final done = shunts;

    return Semantics(
      button: true,
      label: '${tray.name}, ${tray.rows} by ${tray.cols}',
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
                        tray.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tray.winnable
                            ? '${tray.rows} by ${tray.cols}, home in '
                                '${tray.fewest}'
                            : '${tray.rows} by ${tray.cols}, never '
                                'comes home',
                        style: TextStyle(
                          color:
                              tray.winnable ? Palette.inkDim : Palette.bad,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done != null)
                  Text(
                    'home in $done',
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
