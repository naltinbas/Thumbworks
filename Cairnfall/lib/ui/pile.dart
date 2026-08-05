import 'package:flutter/material.dart';

import '../stones/cairn.dart';
import 'palette.dart';

/// One cairn, as a pile of stones.
class Pile extends StatelessWidget {
  const Pile({
    super.key,
    required this.cairn,
    required this.picked,
    required this.worth,
    this.going = 0,
    this.onTap,
  });

  final Cairn cairn;

  /// Whether this is the cairn being taken from.
  final bool picked;

  /// What it is worth, or null when the numbers are not on show.
  final int? worth;

  /// How many stones are about to come off, drawn differently so a take can
  /// be seen before it is made.
  final int going;

  final VoidCallback? onTap;

  /// How wide a pile gets before it starts another row.
  static const across = 5;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          '${cairn.rule.name}, ${cairn.stones} stones'
          '${worth == null ? '' : ', worth $worth'}',
      // The text inside is left out of what is announced: the label above
      // already says all of it, and a node carrying both comes out as
      // neither.
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Palette.moor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: picked ? Palette.going : Palette.ledge,
                width: picked ? 1.8 : 1.1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: across * 16.0,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (var i = 0; i < cairn.stones; i++)
                        _Stone(going: i >= cairn.stones - going),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${cairn.stones}',
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  cairn.rule.name,
                  style: const TextStyle(color: Palette.inkDim, fontSize: 11),
                ),
                if (worth != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.ledge,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'worth $worth',
                      style: const TextStyle(
                        color: Palette.lichen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stone extends StatelessWidget {
  const _Stone({required this.going});

  final bool going;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: going ? Palette.going : Palette.stone,
      shape: BoxShape.circle,
      border: Border.all(
        color: going ? Palette.going : Palette.stoneEdge,
        width: 1,
      ),
    ),
  );
}
