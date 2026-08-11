import 'package:flutter/material.dart';

import '../best.dart';
import '../toss/wagers.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the tables to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.taproom,
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
                'Pennygill',
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
                  'Call three flips. The house calls after you, and that '
                  'is the whole trick.',
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
                  itemCount: Wagers.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _WagerRow(
                    number: number,
                    conceded: best?.concededFor(Wagers.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _WagerRow extends StatelessWidget {
  const _WagerRow({
    required this.number,
    required this.conceded,
    required this.onPlay,
  });

  final int number;

  /// The cleanest this table has been taken, or null.
  final int? conceded;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final wager = Wagers.at(number);
    final won = conceded;

    final story = wager.theyCallFirst
        ? 'the house calls first: the one table to play'
        : wager.evenTable
            ? 'the house answers your opposite: even at last'
            : wager.forced != null
                ? 'you are held to ${wager.forced!.said}: the sucker\'s '
                    'seat'
                : 'you call, the house calls after';

    return Semantics(
      button: true,
      label: wager.name,
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.board,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: won != null ? Palette.good : Palette.line,
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
                        wager.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$story, first to ${wager.stakes}',
                        style: TextStyle(
                          color: wager.theyCallFirst || wager.evenTable
                              ? Palette.inkDim
                              : Palette.house,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (won != null)
                  Text(
                    'taken, $won conceded',
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
