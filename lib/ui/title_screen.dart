import 'package:flutter/material.dart';

import '../tune/tune.dart';
import '../tune/tunes.dart';
import 'palette.dart';

/// The way in: pick a tune.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.onPlay});

  final ValueChanged<Tune> onPlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            children: [
              const _Mark(),
              const SizedBox(height: 24),
              const Text(
                'Chimefall',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Four lanes. Tap each one as it lands.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Palette.stage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.line, width: 1.1),
                ),
                child: const Column(
                  children: [
                    Text(
                      'The music and the notes are one list',
                      style: TextStyle(
                        color: Palette.perfect,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Every sound you hear is played by a note falling down '
                      'the screen, because they are written down once and the '
                      'sound is made from them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              for (final tune in Tunes.all) ...[
                _Pick(tune: tune, onPlay: () => onPlay(tune)),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The mark: four notes falling, one per lane.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 150,
        height: 110,
        child: CustomPaint(painter: _MarkPainter()),
      );
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lane = size.width / Tune.lanes;
    const heights = [0.66, 0.42, 0.20, 0.52];

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 4, size.width, 3),
      Paint()..color = Palette.line,
    );
    for (var i = 0; i < Tune.lanes; i++) {
      final box = Rect.fromCenter(
        center: Offset((i + 0.5) * lane, size.height * heights[i]),
        width: lane * 0.66,
        height: lane * 0.30,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(box.height * 0.35)),
        Paint()..color = Palette.of(i),
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}

class _Pick extends StatelessWidget {
  const _Pick({required this.tune, required this.onPlay});

  final Tune tune;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final perSecond = tune.count / tune.seconds;
    final howHard = perSecond < 1.6
        ? 'gentle'
        : perSecond < 3.4
            ? 'brisk'
            : 'relentless';

    return Semantics(
      button: true,
      label: '${tune.name}, $howHard',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Palette.stage,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.line, width: 1.1),
          ),
          // The name and the line under it give way before the arrow does:
          // three facts and a beats-a-minute run off the side of a 320 point
          // phone otherwise.
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tune.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$howHard · ${tune.count} notes · '
                      '${tune.beatsPerMinute.round()} a minute',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_arrow_rounded, color: Palette.perfect),
            ],
          ),
        ),
      ),
    );
  }
}
