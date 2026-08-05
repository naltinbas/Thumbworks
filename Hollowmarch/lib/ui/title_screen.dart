import 'package:flutter/material.dart';

import '../best.dart';
import '../pegs/boards.dart';
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
                'Hollowmarch',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A peg jumps its neighbour and the one it passed comes out. '
                'Leave one standing.',
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
                  moves: best?.movesFor(Boards.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Boards.count} boards'
                    : '$done of ${Boards.count} finished',
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
          color: Palette.wood,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.grain, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'The number on a board is the fewest moves there are',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'A move is one peg jumping, once or several times running. Every '
              'number here comes from walking every position the board has, so '
              'it is the fewest and not merely somebody\'s best. The last '
              'board is too big to walk, and says so.',
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
    required this.moves,
    required this.onPlay,
  });

  final int number;
  final Board board;

  /// The fewest moves this board has been finished in, or null.
  final int? moves;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = moves != null;
    final perfect = board.par != null && moves == board.par;

    return Semantics(
      button: true,
      label: '${board.name}, ${board.hollows} hollows',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.wood,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: perfect ? Palette.good : Palette.grain,
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
                      board.par == null
                          ? '${board.hollows} hollows · no fewest known'
                          : '${board.hollows} hollows · '
                              '${board.par} moves',
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
                    done ? '$moves' : '-',
                    style: TextStyle(
                      color: perfect
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
                    'your best',
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
