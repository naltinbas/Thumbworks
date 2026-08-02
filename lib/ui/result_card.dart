import 'package:flutter/material.dart';

import '../sim/run.dart';
import '../sim/waves.dart';
import 'palette.dart';

/// What comes up when the run ends.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.run,
    required this.onAgain,
    required this.onLeave,
  });

  final Run run;
  final VoidCallback onAgain;
  final VoidCallback onLeave;

  bool get _held => run.ending == Ending.held;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.veil.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _held ? 'The lane holds' : 'The keep falls',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _held ? Palette.good : Palette.keep,
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _held
                    ? 'All ${Waves.count} waves, with ${run.keep} of the keep left.'
                    : 'Wave ${run.wave + 1} of ${Waves.count} was the one.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.ink, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                '${run.built.length} towers · '
                '${(run.seconds / 60).floor()}m ${(run.seconds % 60).round()}s',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _Button(label: 'Another run', filled: true, onTap: onAgain),
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
              color: filled ? Palette.ember : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filled ? Palette.ember : Palette.lane,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: filled ? Palette.night : Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
