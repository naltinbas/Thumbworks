import 'package:flutter/material.dart';

import '../game/odds.dart';
import '../game/rules.dart';
import 'palette.dart';

/// What each of the three moves is worth, in games out of a hundred.
///
/// Not a hint and not a nudge. It is the same number the other player is
/// using, put where you can see it — the whole difference between the two of
/// you is meant to be that they always take the best one.
class OddsStrip extends StatelessWidget {
  const OddsStrip({super.key, required this.chance, required this.waiting});

  final Chance chance;

  /// Whether it is the other player's move, in which case these are their
  /// odds and not yours.
  final bool waiting;

  static String asShare(double chance) =>
      '${(chance * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Row(
          children: [
            for (final move in Move.values) ...[
              Expanded(
                child: _One(
                  label: switch (move) {
                    Move.bank => 'bank',
                    Move.one => 'one',
                    Move.two => 'two',
                  },
                  chance: chance.of(move),
                  best: chance.best == move,
                  dim: waiting,
                ),
              ),
              if (move != Move.two) const SizedBox(width: 8),
            ],
          ],
        ),
      );
}

class _One extends StatelessWidget {
  const _One({
    required this.label,
    required this.chance,
    required this.best,
    required this.dim,
  });

  final String label;
  final double chance;
  final bool best;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final colour = dim
        ? Palette.inkDim
        : best
            ? Palette.good
            : Palette.ink;

    return Semantics(
      label: '$label wins ${OddsStrip.asShare(chance)}'
          '${best ? ', the best of the three' : ''}',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Palette.felt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: best && !dim ? Palette.good : Palette.rail,
            width: 1.1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Palette.inkDim, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              OddsStrip.asShare(chance),
              style: TextStyle(
                color: colour,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
