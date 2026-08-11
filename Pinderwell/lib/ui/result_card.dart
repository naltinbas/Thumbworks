import 'package:flutter/material.dart';

import '../drive/play.dart';
import 'palette.dart';

/// The card under a drive that has ended, one way or the other.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.best,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Play play;

  /// Whether this beat what was written down before.
  final bool best;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    if (!play.won) {
      return 'The last push was the pinder\'s, and the fee is his. '
          'Somewhere back down the drive she stood on a rung.';
    }
    if (play.made == play.field.fewest) {
      return 'The ewe is penned on ${play.made} pushes, and no drive here '
          'does it on fewer.';
    }
    return 'The ewe is penned on ${play.made} pushes. It can be forced on '
        '${play.field.fewest}.';
  }

  @override
  Widget build(BuildContext context) {
    final well = play.won && play.made == play.field.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Palette.byre,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: well
                ? Palette.good
                : play.won
                    ? Palette.wall
                    : Palette.bad,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: play.won ? 'the fee is won' : 'the fee is lost',
              child: ExcludeSemantics(
                child: Text(
                  play.field.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _line,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: well
                    ? Palette.good
                    : play.won
                        ? Palette.inkDim
                        : Palette.bad,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            if (best) ...[
              const SizedBox(height: 3),
              const Text(
                'Fewer than last time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Fields', onTap: onLeave)),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Next', onTap: onNext, lit: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, this.lit = false});

  final String label;
  final VoidCallback onTap;
  final bool lit;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: lit ? Palette.wall : Palette.moor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.wall, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
