import 'package:flutter/material.dart';

import '../best.dart';
import '../till/rounds.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: the counter book, a customer to a line.
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
                'Groatsworth',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 33,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Count each amount out in the fewest coins the till will '
                'allow. The till is the old English money, and the old money '
                'does not play fair.',
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
              for (var i = 0; i < Rounds.count; i++) ...[
                _Pick(
                  number: i,
                  round: Rounds.at(i),
                  coins: best?.coinsFor(Rounds.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Rounds.count} customers'
                    : '$done of ${Rounds.count} served',
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
              'The biggest coin first is not always fewest',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Four shillings is two florins. Reach for the half crown first, '
              'the way anybody behind a counter would, and it takes three '
              'coins instead. The old coinage really did this, the new '
              'decimal coins never do, and both facts are checked here on '
              'every amount up to five pounds.',
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
    required this.round,
    required this.coins,
    required this.onPlay,
  });

  final int number;
  final Round round;

  /// The fewest coins this round has been counted out in, or null.
  final int? coins;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = coins != null;
    final tight = coins == round.fewest;

    return Semantics(
      button: true,
      label: '${round.name}, ${round.spoken}',
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
                      round.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${round.spoken} · '
                      '${round.till.name.toLowerCase()} · '
                      '${round.fewest} coins',
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
                    done ? '$coins' : '-',
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
                    'coins',
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
