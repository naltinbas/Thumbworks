import 'package:flutter/material.dart';

import '../game/rules.dart';
import 'palette.dart';

/// One player's standing: what they have banked, and how near that is.
class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.name,
    required this.score,
    required this.mine,
    required this.toMove,
    required this.turn,
  });

  final String name;
  final int score;

  /// Whether this is the player holding the phone.
  final bool mine;

  final bool toMove;

  /// What this player's turn has made and not banked, drawn on the end of the
  /// bar in a lighter shade — because what is at stake is the difference
  /// between what you have and what you would have.
  final int turn;

  @override
  Widget build(BuildContext context) {
    final colour = Palette.forWho(mine);
    final banked = (score / Rules.target).clamp(0.0, 1.0);
    final riding =
        ((score + turn) / Rules.target).clamp(0.0, 1.0) - banked;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      decoration: BoxDecoration(
        color: Palette.felt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: toMove ? colour : Palette.rail,
          width: toMove ? 1.6 : 1.1,
        ),
      ),
      child: Column(
        // Stretch, not start: a column that sizes its children to what they
        // ask for gives the bar below no width at all, because a bar made of
        // flexible pieces asks for none.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: toMove ? colour : Palette.inkDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$score',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (banked * 1000).round(),
                    child: ColoredBox(color: colour),
                  ),
                  Expanded(
                    flex: (riding * 1000).round(),
                    child: ColoredBox(color: colour.withValues(alpha: 0.42)),
                  ),
                  Expanded(
                    flex: ((1 - banked - riding) * 1000).round(),
                    child: const ColoredBox(color: Palette.rail),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
