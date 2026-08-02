import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/game.dart';
import 'palette.dart';

/// The line above the board: whose move it is, and what it is for.
class TurnBar extends StatelessWidget {
  const TurnBar({
    super.key,
    required this.game,
    required this.playing,
    required this.thinking,
    required this.onBack,
  });

  final Game game;

  /// The side the player has.
  final Side playing;

  /// Whether the opponent is thinking right now.
  final bool thinking;

  final VoidCallback onBack;

  /// What the side to move is trying to do, said once so a player who has
  /// forgotten does not have to leave the game to find out.
  static String aim(Side side) => side == Side.raiders
      ? 'take the king'
      : 'get the king to a corner';

  @override
  Widget build(BuildContext context) {
    final turn = game.board.turn;
    final mine = turn == playing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Leave the game',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Dot(side: turn),
                    const SizedBox(width: 8),
                    Text(
                      thinking
                          ? 'Thinking'
                          : mine
                              ? 'Your move'
                              : 'Their move',
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  mine ? aim(turn) : '',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 13),
                ),
              ],
            ),
          ),
          _Taken(game: game),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.side});

  final Side side;

  @override
  Widget build(BuildContext context) => Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: side == Side.raiders ? Palette.raider : Palette.guard,
        ),
      );
}

/// How many men each side has lost, which is the only number in this game.
class _Taken extends StatelessWidget {
  const _Taken({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final raidersLost = 12 - game.board.count(Piece.raider);
    final guardsLost = 4 - game.board.count(Piece.guard);
    if (raidersLost == 0 && guardsLost == 0) return const SizedBox.shrink();

    return Row(
      children: [
        if (raidersLost > 0) _Lost(count: raidersLost, colour: Palette.raider),
        if (raidersLost > 0 && guardsLost > 0) const SizedBox(width: 10),
        if (guardsLost > 0) _Lost(count: guardsLost, colour: Palette.guard),
      ],
    );
  }
}

class _Lost extends StatelessWidget {
  const _Lost({required this.count, required this.colour});

  final int count;
  final Color colour;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colour.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: const TextStyle(color: Palette.inkDim, fontSize: 15),
          ),
        ],
      );
}

/// Take back, and start again.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.onBack,
    required this.canBack,
    required this.onAgain,
  });

  final VoidCallback onBack;
  final bool canBack;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _Button(
              label: 'Take it back',
              icon: Icons.undo_rounded,
              onTap: canBack ? onBack : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Button(
              label: 'Start again',
              icon: Icons.refresh_rounded,
              onTap: onAgain,
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dead = onTap == null;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Palette.board,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.rule, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: dead ? Palette.rule : Palette.inkDim,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: dead ? Palette.rule : Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
