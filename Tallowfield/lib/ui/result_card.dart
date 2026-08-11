import 'package:flutter/material.dart';

import '../garden/play.dart';
import 'palette.dart';

/// The card under a settled evening.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.play,
    required this.best,
    required this.hints,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Play play;

  /// Whether this beat what was written down before.
  final bool best;

  /// Askings used this evening.
  final int hints;

  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  String get _line {
    final cost = play.slips == 0 && hints == 0
        ? ' Read clean, first time, unasked.'
        : ' ${play.slips} slip${play.slips == 1 ? '' : 's'}, '
            '$hints asking${hints == 1 ? '' : 's'}.';
    if (play.talliesTrue) {
      if (play.evening.snuffed.isEmpty) {
        return 'All was well, and you said so.$cost';
      }
      return 'Lamp ${play.named} it was: the tallies told the truth and '
          'you read them.$cost';
    }
    return 'You read the tallies right, and they were wrong: the draught '
        'was at lamps ${play.evening.snuffed.join(" and ")}, and their two '
        'beds complained as one third. One fault the hedges find; two '
        'they mistake.$cost';
  }

  @override
  Widget build(BuildContext context) {
    final honest = play.talliesTrue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Palette.wall,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: honest ? Palette.good : Palette.complaint,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: 'the evening is read',
              child: ExcludeSemantics(
                child: Text(
                  play.evening.name,
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
                color: honest ? Palette.good : Palette.complaint,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            if (best) ...[
              const SizedBox(height: 3),
              const Text(
                'Cleaner than last time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Evenings', onTap: onLeave)),
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
                color: lit ? Palette.edge : Palette.dusk,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
