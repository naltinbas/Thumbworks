import 'package:flutter/material.dart';

import '../best.dart';
import '../plank/crossing.dart';
import '../plank/play.dart';
import 'plankview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One crossing, made move by move.
class PlankScreen extends StatefulWidget {
  const PlankScreen({super.key, required this.crossing});

  final Crossing crossing;

  @override
  State<PlankScreen> createState() => PlankScreenState();
}

class PlankScreenState extends State<PlankScreen> {
  late Play play;

  /// The pen the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.crossing);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.crossing.name));
      }
    });
  }

  void _tap(int? pen) {
    if (pen == null || play.isOver) return;
    setState(() {
      play = play.tap(pen);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.crossing.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.crossing.name);
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
      play = Play.of(widget.crossing);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Move the beast in the ringed pen.';
    }
    if (play.isDone) {
      return 'Crossed: sheep and goats have changed ends in ${play.moves} moves.';
    }
    if (play.stuck) {
      return 'Stuck: nobody can move. Take a move back.';
    }
    return 'Moves ${play.moves}; ${play.movers.length} '
        'beast${play.movers.length == 1 ? '' : 's'} may move.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.crossing.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a beast to move it forward, a step into the empty '
                  'pen or a jump over one of the other kind: '
                  '${widget.crossing.task}.',
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
                      painter: PlankView(
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
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'moves ${play.moves}'
                      '${widget.crossing.winnable ? ' of ${widget.crossing.moves}' : ''}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.stuck ? Palette.bad : Palette.line),
                    label: Text(
                      play.stuck ? 'stuck' : 'may move ${play.movers.length}',
                      style: TextStyle(
                          color: play.stuck ? Palette.bad : Palette.inkDim,
                          fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'order ${play.order}',
                      style: const TextStyle(
                          color: Palette.mover, fontSize: 13),
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
