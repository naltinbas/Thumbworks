import 'package:flutter/material.dart';

import '../best.dart';
import '../thread/boards.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a board.
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
                'Skeinmoor',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join each pair of ends, cross nothing, and leave no cell '
                'bare.',
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
              for (var i = 0; i < Boards.count; i++) ...[
                _Pick(
                  number: i,
                  board: Boards.at(i),
                  hints: best?.hintsFor(Boards.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Boards.count} boards'
                    : '$done of ${Boards.count} filled',
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
          color: Palette.peat,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.furrow, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Every board has exactly one answer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Not one that was found — the only one there is. Each board was '
              'handed to a solver that walks every way of filling it, and any '
              'board with a second way was thrown out. So nothing here is '
              'guesswork: whatever you work out is the answer.',
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
    required this.board,
    required this.hints,
    required this.onPlay,
  });

  final int number;
  final Board board;

  /// The fewest hints this board has been filled with, or null.
  final int? hints;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = hints != null;
    final alone = hints == 0;

    return Semantics(
      button: true,
      label: '${board.name}, ${board.side} by ${board.side}, '
          '${board.threads} threads',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.peat,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alone ? Palette.good : Palette.furrow,
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
                      board.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${board.side}×${board.side} · '
                      '${board.threads} threads',
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
                    done ? 'filled' : '—',
                    style: TextStyle(
                      color: alone
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (done)
                    Text(
                      alone ? 'on your own' : '$hints looked at',
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 11,
                      ),
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
