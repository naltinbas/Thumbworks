import 'package:flutter/material.dart';

import '../best.dart';
import '../poll/level.dart';
import '../poll/play.dart';
import 'pollview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the count as it stands.
class PollScreen extends StatefulWidget {
  const PollScreen({super.key, required this.level});

  final Level level;

  @override
  State<PollScreen> createState() => PollScreenState();
}

class PollScreenState extends State<PollScreen> {
  late Play play;

  /// What the show-me points at, or null: 0 Ash, 1 Birch, 2 back.
  int? pointing;

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

  void _draw(bool ash) {
    if (play.isOver) return;
    setState(() {
      play = play.draw(ash);
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
    if (play.gaveUp) return 'The last ballot lands the count level, as it must with four to four: no order keeps Ash ahead throughout.';
    if (play.isDone) return 'As asked. Counted through: level ${play.levelsSoFar} time${play.levelsSoFar == 1 ? '' : 's'}, the lead changed hands ${play.changesSoFar}, Ash ${play.aheadSoFar ? 'ahead throughout' : play.neverBehindSoFar ? 'never behind' : 'behind at some point'}.';
    if (play.drawn.isEmpty) return 'Nothing drawn yet: ${play.ashLeft} Ash and ${play.birchLeft} Birch in the box.';
    final standing = play.lead > 0 ? 'Ash ahead by ${play.lead}' : play.lead < 0 ? 'Birch ahead by ${-play.lead}' : 'level';
    if (play.isComplete) return 'Counted through, $standing, but not as asked: take ballots back and draw again.';
    return '${play.drawn.length} drawn, $standing; ${play.ashLeft} Ash and ${play.birchLeft} Birch left in the box.';
  }

  Widget _drawer(bool ash) {
    final lit = pointing == (ash ? 0 : 1);
    final left = ash ? play.ashLeft : play.birchLeft;
    return OutlinedButton(
      key: Key(ash ? 'ash' : 'birch'),
      onPressed: left > 0 ? () => _draw(ash) : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: lit ? Palette.shown : (ash ? Palette.ash : Palette.birch),
        side: BorderSide(color: lit ? Palette.shown : Palette.line),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(44, 36),
        visualDensity: VisualDensity.compact,
      ),
      child: Text('Draw ${ash ? 'Ash' : 'Birch'}, $left left'),
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
                  'Draw the ballots from the box one at a time, Ash or Birch, '
                  'and watch the lead: ${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: PollView(
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
                      _drawer(true),
                      const SizedBox(width: 10),
                      _drawer(false),
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
                      'lead ${play.lead > 0 ? '+' : ''}${play.lead}',
                      style: TextStyle(
                          color: play.lead > 0 ? Palette.ahead : play.lead < 0 ? Palette.behind : Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'level ${play.levelsSoFar}, turned ${play.changesSoFar}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'draws ${play.moves}',
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
