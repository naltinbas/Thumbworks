import 'package:flutter/material.dart';

import '../best.dart';
import '../floor/rooms.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the rooms to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.house,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: SizedBox(width: 132, height: 132, child: Mark()),
              ),
              const SizedBox(height: 12),
              const Text(
                'Boardleigh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  'Lay two-cell planks until the whole room is '
                  'floored.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Palette.inkDim,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
                  itemCount: Rooms.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _RoomRow(
                    number: number,
                    askings: best?.askingsFor(Rooms.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.number,
    required this.askings,
    required this.onPlay,
  });

  final int number;

  /// The fewest askings this room has been floored with, or null.
  final int? askings;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final room = Rooms.at(number);
    final done = askings;

    return Semantics(
      button: true,
      label: room.name,
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: done != null ? Palette.good : Palette.line,
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        room.winnable
                            ? '${room.wide} by ${room.high}, lays '
                                '${room.ways} way'
                                '${room.ways == 1 ? '' : 's'}'
                            : '${room.wide} by ${room.high} less two '
                                'corners, and no laying floors it',
                        style: TextStyle(
                          color:
                              room.winnable ? Palette.inkDim : Palette.bad,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done != null)
                  Text(
                    done == 0 ? 'laid unasked' : 'laid, asked $done',
                    style: const TextStyle(
                      color: Palette.good,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: Palette.inkDim,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
