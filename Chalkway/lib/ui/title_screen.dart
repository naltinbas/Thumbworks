import 'package:flutter/material.dart';

import '../done.dart';
import '../sim/levels.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a level.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.done, required this.onPlay});

  final Done? done;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final solved = done?.count ?? 0;

    return Scaffold(
      backgroundColor: Palette.slateDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                width: 108,
                height: 108,
                child: Mark(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chalkway',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Draw a line. Let the ball go.',
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
              for (var i = 0; i < Levels.count; i++) ...[
                _Pick(
                  number: i,
                  level: Levels.at(i),
                  chalk: done?.chalkFor(Levels.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                solved == 0
                    ? '${Levels.count} levels'
                    : '$solved of ${Levels.count} solved',
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
          color: Palette.slate,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.fixed, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Every level ships with a line that solves it',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ring,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not a note that says it can be done: an actual drawing, which '
              'the tests draw and then watch the ball arrive. Nothing here is '
              'possible only in theory.',
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
    required this.level,
    required this.chalk,
    required this.onPlay,
  });

  final int number;
  final Level level;

  /// The least chalk this one has been solved with, or null.
  final double? chalk;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final solved = chalk != null;

    return Semantics(
      button: true,
      label: '${level.name}${solved ? ', solved' : ''}',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.slate,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: solved ? Palette.ring : Palette.fixed,
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
                      level.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      solved
                          ? 'solved with ${chalk!.toStringAsFixed(1)} chalk'
                          : '${level.ink.toStringAsFixed(0)} chalk'
                              '${level.spikes.isEmpty ? '' : ' · spikes'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: solved ? Palette.ring : Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                solved ? Icons.check_rounded : Icons.edit_rounded,
                size: 20,
                color: solved ? Palette.ring : Palette.inkDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
