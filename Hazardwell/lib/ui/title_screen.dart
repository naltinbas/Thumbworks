import 'package:flutter/material.dart';

import '../best.dart';
import '../game/odds.dart';
import '../game/rules.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in.
class TitleScreen extends StatelessWidget {
  const TitleScreen({
    super.key,
    required this.best,
    required this.odds,
    required this.onPlay,
  });

  final Best? best;

  /// The table of odds, or null while it is still being worked out.
  final Odds? odds;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ready = odds != null;
    final played = best?.played ?? 0;

    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(width: 108, height: 108, child: Mark()),
              const SizedBox(height: 20),
              const Text(
                'Hazardwell',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Race to ${Rules.target}. Roll as long as you dare.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const _Rules(),
              const SizedBox(height: 14),
              _Note(odds: odds),
              const SizedBox(height: 18),
              _Play(ready: ready, onPlay: onPlay),
              const SizedBox(height: 14),
              if (played > 0)
                Text(
                  '${best!.won} won, ${best!.lost} lost · sharpest '
                  '${(best!.sharpest * 100).round()}%',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 13),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rules, which fit in a box.
class _Rules extends StatelessWidget {
  const _Rules();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Palette.felt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.rail, width: 1.1),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Line('One die', 'Adds what it shows. A one ends your turn and '
                'everything the turn made goes with it.'),
            SizedBox(height: 8),
            _Line('Two dice', 'Adds both, and double that if they match. '
                'Either of them a one ends the turn, and two ones take '
                'your score down to nothing.'),
            SizedBox(height: 8),
            _Line('Bank', 'Puts the turn in your score, where nothing can '
                'take it, and hands over.'),
          ],
        ),
      );
}

class _Line extends StatelessWidget {
  const _Line(this.name, this.says);

  final String name;
  final String says;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$name  ',
              style: const TextStyle(
                color: Palette.yours,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: says,
              style: const TextStyle(
                color: Palette.inkDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

/// The one thing worth saying about the game before somebody plays it.
class _Note extends StatelessWidget {
  const _Note({required this.odds});

  final Odds? odds;

  @override
  Widget build(BuildContext context) {
    final ready = odds != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Palette.felt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ready ? Palette.good : Palette.rail,
          width: 1.1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'The house has worked the whole game out',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ready ? Palette.good : Palette.inkDim,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ready
                ? 'A million positions, each one the exact chance of winning '
                    'from there, settled in ${odds!.sweeps} passes. It plays '
                    'the best move every time, it will show you what that is, '
                    'and at the end it will tell you what your mistakes cost.'
                : 'A million positions, each one the exact chance of winning '
                    'from there. It is being worked out now, and it takes a '
                    'moment, and it is worked out here rather than shipped in '
                    'a table you would have to take on trust.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.inkDim,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Play extends StatelessWidget {
  const _Play({required this.ready, required this.onPlay});

  final bool ready;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: ready ? 'Take a seat' : 'Working out the odds',
        child: GestureDetector(
          onTap: ready ? onPlay : null,
          child: Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ready ? Palette.yours : Palette.felt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ready ? Palette.yours : Palette.rail,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                ready ? 'Take a seat' : 'Working out the odds…',
                style: TextStyle(
                  color: ready ? Palette.night : Palette.inkDim,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
