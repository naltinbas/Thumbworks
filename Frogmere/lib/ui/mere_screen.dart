import 'package:flutter/material.dart';

import '../best.dart';
import '../mere/play.dart';
import '../mere/reach.dart';
import '../mere/rules.dart';
import 'mereview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One reach, leapt for frog by frog.
class MereScreen extends StatefulWidget {
  const MereScreen({super.key, required this.reach});

  final Reach reach;

  @override
  State<MereScreen> createState() => MereScreenState();
}

class MereScreenState extends State<MereScreen> {
  late Play play;

  /// The leap the show-me points at, or null.
  Leap? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.reach);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.reach.name));
      }
    });
  }

  void _tap(Pad? pad) {
    if (pad == null || play.isOver) return;
    setState(() {
      play = play.tap(pad);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.reach.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.reach.name);
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
      play = Play.of(widget.reach);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Leap the ringed frog into the ringed pad.';
    }
    if (play.isDone) {
      return 'Reached: a frog on the ${_ordinal(play.reach.reach)} reach.';
    }
    if (play.picked != null) {
      return 'Frog picked; tap an empty pad two along, past a neighbour.';
    }
    if (play.reach.winnable && !play.lands) {
      return 'No road lands from here: take a leap back.';
    }
    return 'Frogs ${play.frogs.length}, weight '
        '${play.weight.toStringAsFixed(3)} against the aim\'s one.';
  }

  static String _ordinal(int n) =>
      const {1: 'first', 2: 'second', 3: 'third', 4: 'fourth', 5: 'fifth'}[n]!;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.reach.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a frog, then an empty pad two along past a '
                  'neighbour, and the neighbour leaves: '
                  '${widget.reach.task}.',
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
                      painter: MereView(
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
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'frogs ${play.frogs.length}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'leaps ${play.moves}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.weight < 1 - 1e-9
                            ? Palette.bad
                            : Palette.line),
                    label: Text(
                      'weight ${play.weight.toStringAsFixed(3)}',
                      style: TextStyle(
                          color: play.weight < 1 - 1e-9
                              ? Palette.bad
                              : Palette.inkDim,
                          fontSize: 13),
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
