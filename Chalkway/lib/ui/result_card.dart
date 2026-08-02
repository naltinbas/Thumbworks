import 'package:flutter/material.dart';

import '../sim/levels.dart';
import '../sim/stroke.dart';
import '../sim/world.dart';
import 'palette.dart';

/// What comes up when a run ends.
///
/// A panel across the bottom rather than a sheet over everything. What a
/// player wants at the end of a run is to see where the ball went — the trail
/// is the whole answer to why the line worked or did not — and a full screen
/// card covers exactly that.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.level,
    required this.world,
    required this.drawing,
    required this.onAgain,
    required this.onNext,
    required this.onLeave,
  });

  final Level level;
  final World world;
  final Drawing drawing;
  final VoidCallback onAgain;
  final VoidCallback onNext;
  final VoidCallback onLeave;

  bool get home => world.ending == Ending.home;

  /// What happened, in as few words as are true.
  String get _what => switch (world.ending) {
        Ending.home => 'In',
        Ending.stuck => 'On a spike',
        Ending.lost => 'Off the board',
        Ending.settled => 'Stopped short',
        Ending.gaveUp => 'Going nowhere',
        Ending.none => '',
      };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          color: Palette.slate,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border.all(
            color: home ? Palette.ring : Palette.fixed,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _what,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: home ? Palette.ring : Palette.spike,
                fontSize: home ? 36 : 24,
                fontWeight: FontWeight.w300,
                letterSpacing: home ? 7 : 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              home
                  ? '${drawing.used.toStringAsFixed(1)} of '
                      '${level.ink.toStringAsFixed(0)} chalk, in '
                      '${world.seconds.toStringAsFixed(1)} seconds'
                  : 'Rub it out and try a different line.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: home ? Palette.ink : Palette.inkDim,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            if (home) ...[
              _Button(label: 'The next one', filled: true, onTap: onNext),
              const SizedBox(height: 9),
              _Button(label: 'This one again', filled: false, onTap: onAgain),
            ] else ...[
              _Button(label: 'Try again', filled: true, onTap: onAgain),
              const SizedBox(height: 9),
              _Button(
                label: 'Back to the levels',
                filled: false,
                onTap: onLeave,
              ),
            ],
          ],
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
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: GestureDetector(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: filled ? Palette.ring : Palette.slateDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? Palette.ring : Palette.fixed,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: filled ? Palette.slateDeep : Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
