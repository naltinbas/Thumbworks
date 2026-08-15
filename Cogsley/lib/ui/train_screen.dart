import 'package:flutter/material.dart';

import '../best.dart';
import '../train/level.dart';
import '../train/play.dart';
import '../train/rules.dart';
import 'trainview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One train, geared peg by peg.
class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key, required this.level});

  final Level level;

  @override
  State<TrainScreen> createState() => TrainScreenState();
}

class TrainScreenState extends State<TrainScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (Aim, int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.level);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.level.name));
      }
    });
  }

  void _tap((int, int, int)? touch) {
    if (touch == null || play.isOver) return;
    setState(() {
      play = touch.$1 == 1 ? play.hold(touch.$2) : play.tap(touch.$2, touch.$3);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
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
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  whyWords(play),
                  style: const TextStyle(
                      color: Palette.ink, fontSize: 14, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _again() {
    setState(() {
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return switch (aim.$1) {
        Aim.tray => 'Take the gear of ${['one', 'two', 'three'][play.level.tray[aim.$2] - 1]} from the tray.',
        Aim.peg => 'Set it on the ringed peg.',
        Aim.lift => 'Lift the gear ringed rust: it is in the way.',
      };
    }
    final (way, jam) = play.turning;
    if (play.isDone) return _tell(way, jam, asked: true);
    if (play.gaveUp) return jam ? 'The ring of three jams: round it the crank would turn both ways.' : 'Thirty placings, and no ring of three that turns.';
    if (play.refused) return 'That peg is too near another gear: teeth would overlap.';
    if (play.held != null) return 'Holding a gear of ${['one', 'two', 'three'][play.heldRadius! - 1]}: tap the peg for it.';
    return _tell(way, jam, asked: false);
  }

  String _tell(List<int> way, bool jam, {required bool asked}) {
    if (jam) return 'Jammed: a ring with an odd count of gears.';
    if (play.level.hasMill) {
      final w = way[1];
      if (w == 0) return 'The mill stands still: no train reaches it.';
      final (n, d) = Rules.speed(play.gears[0], play.gears[1]);
      final speed = d == 1 ? '$n turn${n == 1 ? '' : 's'}' : '$n/$d of a turn';
      return '${asked ? 'As asked: ' : ''}the mill turns ${w > 0 ? 'with' : 'against'} the crank, $speed for every turn of it.';
    }
    final turning = way.where((x) => x != 0).length;
    return '${asked ? 'As asked: ' : ''}$turning of ${play.gears.length} gears turn${play.gears.length == turning ? ', all in a ring' : ''}.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.level.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Take a gear from the tray and tap a peg to set it there, '
                  'teeth meshing when pegs lie the radii apart; tap a set gear '
                  'to lift it: ${widget.level.task}.',
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
                    ).under(tap.localPosition)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: TrainView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              if (!play.isOver)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'set ${play.placed.length} of ${play.level.tray.length}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : play.jam ? Palette.bad : Palette.line),
                    label: Text(
                      play.jam ? 'jammed' : 'turning ${play.ways.where((w) => w != 0).length} of ${play.gears.length}',
                      style: TextStyle(
                          color: play.jam ? Palette.bad : Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'placings ${play.moves}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
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
                  onSham: () => Navigator.of(context).pop(),
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
