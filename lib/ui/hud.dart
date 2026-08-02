import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/yard.dart';
import 'palette.dart';

/// The line above the yard: which one it is, and how it is going.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.number,
    required this.level,
    required this.yard,
    required this.onLeave,
  });

  final int number;
  final Level level;
  final Yard yard;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = yard.pushes > level.par;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the yards',
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
                  'yard ${number + 1} of ${Levels.count}',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: yard.isDone ? Palette.good : Palette.inkDim,
              ),
              const SizedBox(width: 5),
              Text(
                '${yard.onMarks}/${yard.crates.length}',
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Shoves against the par. Walking is not counted anywhere, because
          // walking cannot make a yard worse.
          Semantics(
            label: 'shoves',
            value: '${yard.pushes} of ${level.par}',
            child: Text(
              '${yard.pushes} / ${level.par}',
              style: TextStyle(
                color: over ? Palette.warn : Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Under the yard: taking a shove back, starting again, and asking.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.canUndo,
    required this.saying,
    required this.thinking,
    required this.onUndo,
    required this.onReset,
    required this.onAsk,
  });

  final bool canUndo;

  /// What the game has to say, if it has been asked or if something has gone
  /// wrong.
  final String? saying;

  /// Whether the game is working out what to say.
  final bool thinking;

  final VoidCallback onUndo;
  final VoidCallback onReset;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saying != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Palette.shed,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.wall, width: 1.1),
              ),
              child: Text(
                saying!,
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: 'Undo',
                  icon: Icons.undo_rounded,
                  onTap: canUndo ? onUndo : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(
                  label: 'Again',
                  icon: Icons.refresh_rounded,
                  onTap: canUndo ? onReset : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(
                  label: thinking ? 'Thinking' : 'Show me',
                  icon: thinking
                      ? Icons.hourglass_empty_rounded
                      : Icons.lightbulb_outline_rounded,
                  onTap: thinking ? null : onAsk,
                ),
              ),
            ],
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
          height: 48,
          decoration: BoxDecoration(
            color: Palette.shed,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Palette.wall, width: 1.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: dead ? Palette.wall : Palette.ink,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: dead ? Palette.wall : Palette.ink,
                    fontSize: 14,
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
