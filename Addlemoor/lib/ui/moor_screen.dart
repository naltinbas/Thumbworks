import 'package:flutter/material.dart';

import '../best.dart';
import '../sum/moor.dart';
import '../sum/play.dart';
import 'moorview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One moor, painted stone by stone.
class MoorScreen extends StatefulWidget {
  const MoorScreen({super.key, required this.moor});

  final Moor moor;

  @override
  State<MoorScreen> createState() => MoorScreenState();
}

class MoorScreenState extends State<MoorScreen> {
  late Play play;

  /// The stone and paint the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.moor);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.moor.name));
      }
    });
  }

  void _tap(int stone) {
    if (stone < 1 || play.isOver) return;
    setState(() {
      play = play.tapAt(stone);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.moor.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.moor.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() => pointing = play.next);
  }

  void _why() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.board,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why',
              style: TextStyle(
                color: Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              whyWords(play),
              style: const TextStyle(
                  color: Palette.ink, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _again() {
    setState(() {
      play = Play.of(widget.moor);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the moor says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Paint stone ${aim.$1} '
          '${Palette.paintNames[aim.$2]}.';
    }
    if (play.isDone) {
      return 'Painted: not a bad sum on the moor.';
    }
    if (play.badSums.isNotEmpty) {
      final (x, y, z) = play.badSums.first;
      return '$x and $y make $z, all in one paint: repaint one.';
    }
    return 'No bad sum yet; the row must stand clean when you '
        'stop.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.moor.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a stone to swap its paint: '
                  '${widget.moor.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(Metrics(
                      play,
                      Size(room.maxWidth, room.maxHeight),
                    ).stoneUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: MoorView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (var paint = 0;
                      paint < widget.moor.paints;
                      paint++)
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: Palette.paints[paint]),
                      label: Text(
                        Palette.paintNames[paint],
                        style: TextStyle(
                            color: Palette.paints[paint],
                            fontSize: 13),
                      ),
                    ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.badSum),
                    label: Text(
                      'bad sums ${play.badSums.length}',
                      style: const TextStyle(
                          color: Palette.badSum, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  verdict(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pointing != null
                        ? Palette.shown
                        : play.isDone
                            ? Palette.good
                            : Palette.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              if (play.isOver)
                ResultCard(
                  play: play,
                  fewest: fewest,
                  isRecord: isRecord,
                  onAgain: _again,
                  onMoor: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: play.before == null ? null : _back,
                      child: const Text('Back'),
                    ),
                    TextButton(
                      onPressed: play.isOver ? null : _show,
                      child: const Text('Show me'),
                    ),
                    TextButton(
                      onPressed: _why,
                      child: const Text('Why'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
