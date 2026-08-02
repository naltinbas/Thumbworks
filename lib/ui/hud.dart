import 'package:flutter/material.dart';

import '../sim/levels.dart';
import '../sim/stroke.dart';
import 'palette.dart';

/// The line above the board: which level, and how much chalk is left.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.number,
    required this.level,
    required this.drawing,
    required this.onLeave,
  });

  final int number;
  final Level level;
  final Drawing drawing;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final share = (drawing.left / drawing.ink).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the levels',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'level ${number + 1} of ${Levels.count}',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
            ),
          ),
          // The chalk left, as a stick of it. A number would be exact and
          // meaningless: what a player wants to know is whether there is
          // enough for another go at that line.
          Semantics(
            label: 'chalk left',
            value: '${(share * 100).round()} per cent',
            child: Container(
              width: 74,
              height: 9,
              decoration: BoxDecoration(
                color: Palette.slate,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: share,
                child: Container(
                  decoration: BoxDecoration(
                    color: share < 0.2 ? Palette.spike : Palette.chalk,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rub out, and let go.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.running,
    required this.canRub,
    required this.onGo,
    required this.onRub,
    required this.onAgain,
  });

  final bool running;
  final bool canRub;
  final VoidCallback onGo;
  final VoidCallback onRub;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: _Button(
              label: 'Rub out',
              icon: Icons.undo_rounded,
              onTap: !running && canRub ? onRub : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _Button(
              label: running ? 'Start again' : 'Let go',
              icon: running
                  ? Icons.refresh_rounded
                  : Icons.play_arrow_rounded,
              filled: !running,
              onTap: running ? onAgain : onGo,
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final dead = onTap == null;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: filled ? Palette.ring : Palette.slate,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: filled ? Palette.ring : Palette.fixed,
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: dead
                    ? Palette.fixed
                    : filled
                        ? Palette.slateDeep
                        : Palette.ink,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: dead
                        ? Palette.fixed
                        : filled
                            ? Palette.slateDeep
                            : Palette.ink,
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
