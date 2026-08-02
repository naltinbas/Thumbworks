import 'package:flutter/material.dart';

import '../game/game.dart';
import 'palette.dart';

/// What comes up when the last card goes home.
class WonCard extends StatelessWidget {
  const WonCard({
    super.key,
    required this.game,
    required this.onNext,
    required this.onLeave,
  });

  final Game game;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.feltDark.withValues(alpha: 0.93),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Out',
                style: TextStyle(
                  color: Palette.good,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Deal ${game.number}, in ${game.moves} moves.',
                style: const TextStyle(color: Palette.ink, fontSize: 17),
              ),
              const SizedBox(height: 34),
              _Button(label: 'Next deal', filled: true, onTap: onNext),
              const SizedBox(height: 10),
              _Button(label: 'Back to the book', filled: false, onTap: onLeave),
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
                color: filled ? Palette.good : Palette.slotEdge,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: filled ? Palette.feltDark : Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
