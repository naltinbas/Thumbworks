import 'package:flutter/material.dart';

import '../best.dart';
import '../raise/frame.dart';
import '../raise/frames.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a frame.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final done = best?.done ?? 0;

    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(width: 104, height: 104, child: Mark()),
              const SizedBox(height: 20),
              const Text(
                'Trestlewick',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get a timber frame standing in the fewest days. Nothing goes '
                'up before what it rests on, and there are never enough crews.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const _Note(),
              const SizedBox(height: 20),
              for (var i = 0; i < Frames.count; i++) ...[
                _Pick(
                  number: i,
                  frame: Frames.at(i),
                  days: best?.daysFor(Frames.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Frames.count} frames'
                    : '$done of ${Frames.count} standing',
                style: const TextStyle(color: Palette.inkDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one thing worth saying about the game before somebody plays it.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Palette.verge,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.line, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Two things hold a frame back',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'A run of timbers each resting on the one before cannot be '
              'spread over fewer days than there are timbers in it, however '
              'many crews turn up. And a crew raises one timber a day, so the '
              'work alone takes the timbers divided by the crews. On every '
              'frame here one of those two is exactly the answer, and Why '
              'shows which.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.inkDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.number,
    required this.frame,
    required this.days,
    required this.onPlay,
  });

  final int number;
  final Frame frame;

  /// The fewest days this frame has been raised in, or null.
  final int? days;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = days != null;
    final tight = days == frame.days;

    return Semantics(
      button: true,
      label: '${frame.name}, ${frame.count} timbers',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.verge,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done ? Palette.good : Palette.line,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '${number + 1}',
                  style: const TextStyle(
                    color: Palette.inkDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      frame.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${frame.count} timbers · '
                      '${frame.crews} crews · '
                      '${frame.days} days',
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    done ? '$days' : '-',
                    style: TextStyle(
                      color: tight
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Text(
                    'days',
                    style: TextStyle(color: Palette.inkDim, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
