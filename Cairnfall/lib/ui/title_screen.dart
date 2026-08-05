import 'package:flutter/material.dart';

import '../best.dart';
import '../stones/rounds.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a round.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final won = best?.won ?? 0;

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
                'Cairnfall',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take stones off the cairns. Whoever takes the last one wins.',
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
                  standing: best?.standingOn(Rounds.at(i).name) ?? 0,
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                won == 0
                    ? '${Rounds.count} rounds'
                    : '$won of ${Rounds.count} won',
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
          color: Palette.moor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.ledge, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Every round can be won, and it will show you how',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.lichen,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'You move first and every round starts winnable — a test says '
              'so. The other player never slips. Turn the numbers on and you '
              'can see exactly what it is doing: each cairn is worth a '
              'number, and the move that wins is the one that makes them all '
              'come to nothing.',
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
    required this.standing,
    required this.onPlay,
  });

  final int number;
  final Round round;

  /// Nought for not yet, one for won, two for won without a slip.
  final int standing;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${round.name}, ${round.about}',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.moor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: standing > 1 ? Palette.lichen : Palette.ledge,
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
                      round.about,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                standing > 1
                    ? Icons.verified_rounded
                    : standing > 0
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                size: 20,
                color: standing > 1
                    ? Palette.lichen
                    : standing > 0
                        ? Palette.inkDim
                        : Palette.ledge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
