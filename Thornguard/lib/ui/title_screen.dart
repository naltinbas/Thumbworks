import 'package:flutter/material.dart';

import '../game/board.dart';
import '../opponent.dart';
import 'board_painter.dart';
import 'palette.dart';

/// The way in: which side, how hard, play.
///
/// Both choices are on this screen rather than behind a settings button,
/// because they are the only two the game has and a player wants to change
/// them between games rather than once ever.
class TitleScreen extends StatelessWidget {
  const TitleScreen({
    super.key,
    required this.playing,
    required this.strength,
    required this.onSide,
    required this.onStrength,
    required this.onPlay,
  });

  final Side playing;
  final Strength strength;
  final ValueChanged<Side> onSide;
  final ValueChanged<Strength> onStrength;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: BoardPainter(
                    board: Board.opening(),
                    metrics: Metrics(const Size(140, 140)),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Thornguard',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Twelve raiders against a king and four guards.\n'
                'Everything moves like a rook.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              _Pick<Side>(
                title: 'Your side',
                value: playing,
                onPick: onSide,
                options: const {
                  Side.guards: 'Guards — get the king to a corner',
                  Side.raiders: 'Raiders — take the king',
                },
                tints: const {
                  Side.guards: Palette.guard,
                  Side.raiders: Palette.raider,
                },
              ),
              const SizedBox(height: 18),
              _Pick<Strength>(
                title: 'The opponent',
                value: strength,
                onPick: onStrength,
                options: {
                  for (final one in Strength.values)
                    one: '${one.label} — ${_says(one)}',
                },
                tints: {for (final one in Strength.values) one: Palette.inkDim},
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onPlay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.good,
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static String _says(Strength strength) => switch (strength) {
        Strength.steady => 'sees one move ahead',
        Strength.sharp => 'sets traps',
        Strength.deep => 'plans, and takes a moment',
      };
}

class _Pick<T> extends StatelessWidget {
  const _Pick({
    required this.title,
    required this.value,
    required this.onPick,
    required this.options,
    required this.tints,
  });

  final String title;
  final T value;
  final ValueChanged<T> onPick;
  final Map<T, String> options;
  final Map<T, Color> tints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Palette.inkDim, fontSize: 13),
        ),
        const SizedBox(height: 8),
        for (final entry in options.entries) ...[
          _Row(
            label: entry.value,
            on: entry.key == value,
            tint: tints[entry.key]!,
            onTap: () => onPick(entry.key),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.on,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final bool on;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: on ? Palette.board : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: on ? tint : Palette.rule,
              width: on ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? tint : Palette.rule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: on ? Palette.ink : Palette.inkDim,
                    fontSize: 15,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400,
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
