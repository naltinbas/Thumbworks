import 'package:flutter/material.dart';

import '../best.dart';
import '../feint/level.dart';
import '../feint/play.dart';
import 'feintview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the number and the base on their dials and the test they sit.
class FeintScreen extends StatefulWidget {
  const FeintScreen({super.key, required this.level});

  final Level level;

  @override
  State<FeintScreen> createState() => FeintScreenState();
}

class FeintScreenState extends State<FeintScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

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

  void _turn(String which, int by) {
    if (play.isOver) return;
    setState(() {
      play = play.step(which, by);
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
    if (aim != null) return Play.pointed(aim);
    final head = '${play.number} on base ${play.base}, ${madeOf(play)}: the base raised to ${play.number - 1} lands on ${play.landing}, ${play.passes ? 'so it passes' : 'so it fails'}${play.liar ? ', a liar' : ''}.';
    if (play.gaveUp) return '$head Every prime passes, whatever the base.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _dial(String name, String label, int at) {
    Widget button(int by, IconData icon) {
      final lit = pointing == (name, by);
      return IconButton(
        key: Key('$name${by > 0 ? '+' : ''}$by'),
        onPressed: () => _turn(name, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 36),
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
        if (name == 'n') button(-10, Icons.keyboard_double_arrow_left),
        button(-1, Icons.remove),
        SizedBox(
          width: name == 'n' ? 76 : 58,
          child: Text(
            '$label $at',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.ink, fontSize: 13),
          ),
        ),
        button(1, Icons.add),
        if (name == 'n') button(10, Icons.keyboard_double_arrow_right),
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
                  'Step the number and the base, and watch the base squared '
                  'over and over and the landing it makes: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: FeintView(
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
                    spacing: 8,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [
                      _dial('n', 'number', play.number),
                      _dial('a', 'base', play.base),
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
                      'lands on ${play.landing}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      play.prime ? 'prime' : 'composite',
                      style: const TextStyle(
                          color: Palette.gold, fontSize: 13),
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
