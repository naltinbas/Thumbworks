import 'package:flutter/material.dart';

import 'palette.dart';

/// The line above the table: which deal, how many moves, how many home.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.number,
    required this.moves,
    required this.home,
    required this.onLeave,
  });

  final int number;
  final int moves;
  final int home;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Leave this deal',
          ),
          Text(
            'Deal $number',
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _Count(value: '$home', of: '52', label: 'home'),
          const SizedBox(width: 16),
          _Count(value: '$moves', label: 'moves'),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, this.of});

  final String value;
  final String label;
  final String? of;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$value $label',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              of == null ? value : '$value/$of',
              style: const TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Palette.inkDim, fontSize: 11),
            ),
          ],
        ),
      );
}

/// Undo, hint, and start the deal again.
///
/// The hint is the one worth having and the reason the solver ships in the
/// app. It does not suggest a move because it looks reasonable — it is a move
/// on a line that finishes the game, or it says there is not one, which is
/// just as useful and much harder to come by.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.canUndo,
    required this.thinking,
    required this.stuck,
    required this.onUndo,
    required this.onHint,
    required this.onAgain,
  });

  final bool canUndo;
  final bool thinking;

  /// Whether the last hint came back saying there is no way on.
  final bool stuck;

  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: _Button(
              label: 'Undo',
              icon: Icons.undo_rounded,
              onTap: canUndo ? onUndo : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _Button(
              label: thinking
                  ? 'Thinking'
                  : stuck
                      ? 'No way on'
                      : 'Hint',
              icon: stuck ? Icons.block_rounded : Icons.lightbulb_outline,
              tint: stuck ? Palette.red : Palette.good,
              onTap: thinking ? null : onHint,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Button(
              label: 'Again',
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
  const _Button({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint = Palette.inkDim,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final dead = onTap == null;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Palette.feltDark,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Palette.slotEdge, width: 1.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: dead ? Palette.slotEdge : tint),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: dead ? Palette.slotEdge : Palette.ink,
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
