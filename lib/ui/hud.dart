import 'package:flutter/material.dart';

import '../game/book.dart';
import 'board_view.dart';
import 'palette.dart';

/// The line above the puzzle: which one this is, and how long it has taken.
class PuzzleBar extends StatelessWidget {
  const PuzzleBar({
    super.key,
    required this.number,
    required this.elapsed,
    required this.onBack,
  });

  final int number;

  /// Ticking, and rebuilt on its own so the board is not.
  final Animation<double> elapsed;

  final VoidCallback onBack;

  static String face(Duration took) {
    final minutes = took.inMinutes;
    final seconds = took.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the book',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puzzle $number',
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Book.chapterOf(number).title,
                  style: const TextStyle(color: Palette.inkDim, fontSize: 13),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: elapsed,
            builder: (context, _) => Text(
              face(Duration(seconds: elapsed.value.round())),
              style: const TextStyle(
                color: Palette.inkDim,
                fontSize: 17,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The two marks and the way back.
///
/// A toggle rather than a long press. Long pressing to cross off is what a
/// nonogram on a phone usually asks for and it is wrong twice over: it costs
/// half a second every time, and it cannot be dragged, so crossing off a run
/// of six means six long presses. With a toggle both marks are strokes and the
/// only cost is knowing which one is on, which is what the highlight is for.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.mode,
    required this.onMode,
    required this.onUndo,
    required this.canUndo,
  });

  final Mode mode;
  final ValueChanged<Mode> onMode;
  final VoidCallback onUndo;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _Tool(
              label: 'Fill',
              icon: Icons.square_rounded,
              tint: Palette.drawn,
              on: mode == Mode.fill,
              onTap: () => onMode(Mode.fill),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tool(
              label: 'Cross',
              icon: Icons.close_rounded,
              tint: Palette.crossed,
              on: mode == Mode.cross,
              onTap: () => onMode(Mode.cross),
            ),
          ),
          const SizedBox(width: 10),
          // Icon only, and no wider than it has to be. Three labelled buttons
          // do not fit across a 320 point phone, and of the three this is the
          // one whose picture everybody already knows.
          SizedBox(
            width: 60,
            child: _Tool(
              label: 'Undo',
              icon: Icons.undo_rounded,
              tint: Palette.inkDim,
              on: false,
              onTap: canUndo ? onUndo : null,
              showLabel: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.label,
    required this.icon,
    required this.tint,
    required this.on,
    required this.onTap,
    this.showLabel = true,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final bool on;
  final VoidCallback? onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final dead = onTap == null;
    return Semantics(
      button: true,
      selected: on,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          // Tall enough for a thumb that is busy with the board, on a screen
          // where everything else is small on purpose.
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: on ? Palette.ink : Palette.margin,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: on ? Palette.ink : Palette.rule,
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: dead
                    ? Palette.spent
                    : on
                        ? Palette.paper
                        : tint,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: dead
                          ? Palette.spent
                          : on
                              ? Palette.paper
                              : Palette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
