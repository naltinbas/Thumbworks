import 'package:flutter/material.dart';

import '../best.dart';
import '../ticket/level.dart';
import '../ticket/play.dart';
import '../ticket/rules.dart';
import 'ticketview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the ticket on its five dials.
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key, required this.level});

  final Level level;

  @override
  State<TicketScreen> createState() => TicketScreenState();
}

class TicketScreenState extends State<TicketScreen> {
  late Play play;

  /// What the show-me points at, or null.
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

  void _turn(int place, int by) {
    if (play.isOver) return;
    setState(() {
      play = play.turn(place, by);
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
    final head = 'Ticket ${Rules.tell(play.digits)}: sum ${play.sum}, ${play.passes ? 'ends in nought, passes' : 'ends in ${play.sum % 10}, fails'}.';
    if (play.gaveUp) return '$head One slip, always caught.';
    if (play.slipped && !play.passes) return '$head Caught: ${Rules.tell(play.before!.digits)} passed and one digit turned.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _dial(int place) {
    Widget button(int by, IconData icon) {
      final lit = pointing == (place, by);
      return IconButton(
        key: Key('d$place${by > 0 ? '+1' : '-1'}'),
        onPressed: () => _turn(place, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 34),
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          side: BorderSide(color: lit ? Palette.shown : Palette.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(1, Icons.keyboard_arrow_up),
          Text(
            '${play.digits[place]}',
            style: const TextStyle(color: Palette.ink, fontSize: 13),
          ),
          button(-1, Icons.keyboard_arrow_down),
        ],
      ),
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
                  'Turn the five dials, round from 9 to 0 and back, and '
                  'watch the sum and the stamp: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: TicketView(
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
                      for (var i = 0; i < Rules.places; i++) _dial(i),
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
                      'sum ${play.sum}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      play.passes ? 'passes' : 'fails',
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
