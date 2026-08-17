import 'package:flutter/material.dart';

import '../best.dart';
import '../hedge/level.dart';
import '../hedge/play.dart';
import '../hedge/rules.dart';
import 'hedgeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the hedge set to it.
class HedgeScreen extends StatefulWidget {
  const HedgeScreen({super.key, required this.level});

  final Level level;

  @override
  State<HedgeScreen> createState() => HedgeScreenState();
}

class HedgeScreenState extends State<HedgeScreen> {
  late Play play;

  /// What the show-me points at, or null: (dial, way).
  (int, int)? pointing;

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

  void _step(int dial, int by) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.step(dial, by);
      pointing = null;
    });
    if (identical(play, was)) return;
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
    if (aim != null) return Play.pointed(aim);
    if (play.gaveUp) {
      return 'Peeling takes a step off each end of the longest walk, so the '
          'middle is what lies halfway along it, and halfway on a line is one '
          'post or two.';
    }
    final head = 'The hedge peels to ${Rules.tellMiddle(play.middle)} in '
        '${Rules.tellRounds(play.rounds)}.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _dial(int dial) {
    final post = dial + 3;
    Widget button(int by, IconData icon) {
      final lit = pointing == (dial, by);
      return IconButton(
        key: Key('post$post${by > 0 ? '+1' : '-1'}'),
        onPressed: () => _step(dial, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          side: BorderSide(color: lit ? Palette.shown : Palette.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(-1, Icons.remove),
        SizedBox(
          width: 54,
          child: Text(
            '$post on ${play.hanging[dial]}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.ink, fontSize: 13),
          ),
        ),
        button(1, Icons.add),
      ],
    );
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
                  'Hang each post off a different one a tap at a time and '
                  'watch the hedge peel: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: HedgeView(
                    play: play,
                    pointing: pointing,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!play.isOver)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var dial = 0; dial < Rules.hangs; dial++)
                        _dial(dial),
                    ],
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
                        'middle ${play.middle.join(' and ')}',
                        style: const TextStyle(
                            color: Palette.middle, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'rounds ${play.rounds}',
                        style:
                            const TextStyle(color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'taps ${play.moves}',
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
