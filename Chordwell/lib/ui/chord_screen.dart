import 'package:flutter/material.dart';

import '../best.dart';
import '../chord/level.dart';
import '../chord/play.dart';
import '../chord/rules.dart';
import 'wheelview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the wheel and its chords for it.
class ChordScreen extends StatefulWidget {
  const ChordScreen({super.key, required this.level});

  final Level level;

  @override
  State<ChordScreen> createState() => ChordScreenState();
}

class ChordScreenState extends State<ChordScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (int, bool)? pointing;

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

  void _tap(int? peg) {
    if (peg == null || play.isOver) return;
    setState(() {
      play = play.tap(peg);
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
    final n = play.chosen.length;
    final p = play.crossing;
    if (play.gaveUp && p != null) {
      final products = play.products!;
      return 'Crossing at ${Rules.tellPoint(p)}: the products are ${products.$1} and ${products.$2}, and they always agree, 25 less the crossing\'s distance from the middle squared.';
    }
    if (n == 0) return 'No pegs set: tap four pegs, two for each chord.';
    if (n == 1) return 'One peg set at ${Rules.tellPeg(play.peg(0))}: tap another to make the first chord.';
    if (n == 2) return 'Chord ${Rules.tellPeg(play.peg(0))} to ${Rules.tellPeg(play.peg(1))} set: tap two more pegs for the second.';
    if (n == 3) return 'The second chord starts at ${Rules.tellPeg(play.peg(2))}: tap its other end.';
    if (p == null) return 'The chords do not cross inside the wheel: lift a peg and try another.';
    final products = play.products!;
    final head = 'Crossing at ${Rules.tellPoint(p)}: ${Rules.tellLength(Rules.piece2(p, play.peg(0)))} times ${Rules.tellLength(Rules.piece2(p, play.peg(1)))} is ${products.$1} on the one chord, '
        '${Rules.tellLength(Rules.piece2(p, play.peg(2)))} times ${Rules.tellLength(Rules.piece2(p, play.peg(3)))} is ${products.$2} on the other, and 25 less ${p.$1 * p.$1 + p.$2 * p.$2} is ${Rules.power(p)}.';
    return play.isDone ? 'As asked. $head' : head;
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
                  'Tap four pegs of the wheel, two for each chord, and watch '
                  'where the chords cross: ${widget.level.task}.',
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
                      painter: WheelView(
                        play: play,
                        pointing: pointing?.$1,
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
                      'pegs ${play.chosen.length} of 4',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      play.products == null ? 'no crossing' : 'products ${play.products!.$1} and ${play.products!.$2}',
                      style: const TextStyle(
                          color: Palette.crossing, fontSize: 13),
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
