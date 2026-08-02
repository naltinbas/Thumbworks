import 'package:flutter/material.dart';

import '../sim/field.dart';
import '../sim/kinds.dart';
import '../sim/run.dart';
import '../sim/waves.dart';
import 'field_painter.dart';
import 'palette.dart';

/// The way in.
///
/// One decision, which is Play. The rest of it says what the three towers do,
/// because a defence game whose towers are a mystery is a game whose first run
/// is a waste of everybody's time — and there is nowhere else to put it that a
/// player would go and look.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.onPlay});

  final VoidCallback onPlay;

  /// The field with a few towers on it, drawn by the painter that draws the
  /// game, so the mark is the game rather than a picture of it.
  static Run get _mark => Run.fresh(embers: 1000)
      .build(Tower.spark, const Cell(3, 1))
      .build(Tower.frost, const Cell(2, 4))
      .build(Tower.forge, const Cell(2, 6))
      .build(Tower.spark, const Cell(6, 6))
      .build(Tower.forge, const Cell(4, 10));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                height: 150 * Field.rows / Field.columns,
                child: CustomPaint(
                  painter: FieldPainter(
                    run: _mark,
                    metrics: Metrics(
                      Size(150, 150 * Field.rows / Field.columns),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Emberlane',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${Waves.count} waves down one lane.\n'
                'Build beside it. Nothing gets past.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              for (final tower in Tower.values) ...[
                _Line(tower: tower),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onPlay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.ember,
                    foregroundColor: Palette.night,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.tower});

  final Tower tower;

  static String says(Tower tower) => switch (tower) {
        Tower.spark => 'quick, cheap, short reach',
        Tower.forge => 'one heavy shot, slowly',
        Tower.frost => 'almost no damage; halves what it hits',
      };

  @override
  Widget build(BuildContext context) {
    final tint = Palette.of(tower);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Palette.ground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Palette.lane, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            tower.name,
            style: TextStyle(
              color: tint,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              says(tower),
              maxLines: 2,
              style: const TextStyle(color: Palette.inkDim, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tower.cost}',
            style: const TextStyle(
              color: Palette.ember,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
