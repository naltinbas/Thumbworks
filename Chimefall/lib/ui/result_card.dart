import 'package:flutter/material.dart';

import '../play/session.dart';
import 'palette.dart';

/// What comes up when the tune ends.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.session,
    required this.onAgain,
    required this.onLeave,
  });

  final Session session;
  final VoidCallback onAgain;
  final VoidCallback onLeave;

  /// What the go was worth, out of everything.
  double get share =>
      session.possible == 0 ? 0 : session.score / session.possible;

  /// A word for it. Nothing here is a grade out of five stars: a share and a
  /// count say more and cannot be argued with.
  String get _what {
    if (session.countOf(Judgement.missed) == 0) return 'Not one dropped';
    if (share > 0.8) return 'Well played';
    if (share > 0.5) return 'Getting there';
    return 'Have another go';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.veil.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _what,
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${session.score}',
                style: const TextStyle(
                  color: Palette.perfect,
                  fontSize: 54,
                  fontWeight: FontWeight.w200,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${(share * 100).round()} per cent of everything there is',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
              const SizedBox(height: 26),
              _Count(
                judgement: Judgement.perfect,
                count: session.countOf(Judgement.perfect),
              ),
              _Count(
                judgement: Judgement.good,
                count: session.countOf(Judgement.good),
              ),
              _Count(
                judgement: Judgement.missed,
                count: session.countOf(Judgement.missed),
              ),
              const SizedBox(height: 10),
              Text(
                'longest run ${session.best}',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
              const SizedBox(height: 30),
              _Button(label: 'Again', filled: true, onTap: onAgain),
              const SizedBox(height: 10),
              _Button(label: 'Another tune', filled: false, onTap: onLeave),
            ],
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.judgement, required this.count});

  final Judgement judgement;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                switch (judgement) {
                  Judgement.perfect => 'perfect',
                  Judgement.good => 'good',
                  Judgement.missed => 'missed',
                },
                textAlign: TextAlign.right,
                style: TextStyle(color: Palette.say(judgement), fontSize: 15),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 50,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      );
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
              color: filled ? Palette.perfect : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filled ? Palette.perfect : Palette.line,
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
