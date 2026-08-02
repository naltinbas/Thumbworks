import 'package:flutter/material.dart';

import '../sim/journey.dart';
import '../sim/runner.dart';
import 'palette.dart';

/// What comes up when the run ends.
class OverCard extends StatelessWidget {
  const OverCard({
    super.key,
    required this.journey,
    required this.best,
    required this.beat,
    required this.onAgain,
    required this.onLeave,
  });

  final Journey journey;
  final int best;

  /// Whether this run beat what was there before.
  final bool beat;

  final VoidCallback onAgain;
  final VoidCallback onLeave;

  /// What happened, in as few words as are true.
  String get _what => switch (journey.run.ending) {
        Ending.fell => 'Down the gap',
        Ending.spiked => 'Onto the spikes',
        Ending.hit => 'Into the wall',
        _ => 'Stopped',
      };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.veil.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _what,
                style: const TextStyle(
                  color: Palette.spike,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${journey.score}',
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 62,
                  fontWeight: FontWeight.w200,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                beat ? 'the furthest yet' : 'best $best',
                style: TextStyle(
                  color: beat ? Palette.good : Palette.inkDim,
                  fontSize: 15,
                  fontWeight: beat ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),
              _Button(label: 'Again', filled: true, onTap: onAgain),
              const SizedBox(height: 10),
              _Button(label: 'Back to the start', filled: false, onTap: onLeave),
            ],
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: filled ? Palette.good : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filled ? Palette.good : Palette.edge,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: filled ? Palette.sky : Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
