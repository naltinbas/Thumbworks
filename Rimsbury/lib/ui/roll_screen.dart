import 'package:flutter/material.dart';

import '../best.dart';
import '../roll/level.dart';
import '../roll/play.dart';
import '../roll/rules.dart';
import 'rollview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the hoop and the roller set to it.
class RollScreen extends StatefulWidget {
  const RollScreen({super.key, required this.level});

  final Level level;

  @override
  State<RollScreen> createState() => RollScreenState();
}

class RollScreenState extends State<RollScreen> {
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

  void _turn(int which, int by) {
    if (play.isOver) return;
    setState(() {
      play = which == 2 ? play.flip() : play.set(which, by);
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
    if (play.gaveUp) return 'A hoop of one and a roller of six is as near as it comes: 7/6 of a turn, and the trip alone is a turn.';
    if (!play.fits) return 'A roller of ${play.coin} does not fit inside a hoop of ${play.hoop}.';
    final turns = play.turns!;
    final head = 'A hoop of ${play.hoop} and a roller of ${play.coin}, round the ${play.inside ? 'inside' : 'outside'}: '
        '${Rules.fraction(turns)} turn${turns == (1, 1) ? '' : 's'} a trip, ${Rules.fraction(Rules.rim(play.hoop, play.coin))} for the rim and 1 '
        '${play.inside ? 'off' : 'on'} for the trip.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _dial(int which, String name, int at) {
    Widget button(int by, IconData icon) {
      final lit = pointing == (which, by);
      return IconButton(
        key: Key('$name${by > 0 ? '+1' : '-1'}'),
        onPressed: () => _turn(which, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
          width: 66,
          child: Text(
            '$name $at',
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
                  'Size the hoop and the roller a step a tap, send the roller '
                  'round either side, and see the turns a trip makes: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: RollView(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dial(0, 'hoop', play.hoop),
                      const SizedBox(width: 8),
                      _dial(1, 'roller', play.coin),
                    ],
                  ),
                ),
              if (!play.isOver)
                OutlinedButton(
                  key: const Key('side'),
                  onPressed: () => _turn(2, 0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pointing == (2, 0) ? Palette.shown : Palette.ink,
                    side: BorderSide(color: pointing == (2, 0) ? Palette.shown : Palette.line),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    minimumSize: const Size(44, 32),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(play.inside ? 'Round the inside' : 'Round the outside'),
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
                        color: play.isDone ? Palette.good : play.fits ? Palette.line : Palette.bad),
                    label: Text(
                      play.fits ? 'turns ${Rules.fraction(play.turns!)}' : 'does not fit',
                      style: TextStyle(
                          color: play.fits ? Palette.ink : Palette.bad, fontSize: 13),
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
