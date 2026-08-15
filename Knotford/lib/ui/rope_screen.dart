import 'package:flutter/material.dart';

import '../best.dart';
import '../rope/play.dart';
import '../rope/rope.dart';
import '../rope/rules.dart';
import 'ropeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One rope, marked peg by peg.
class RopeScreen extends StatefulWidget {
  const RopeScreen({super.key, required this.rope});

  final Rope rope;

  @override
  State<RopeScreen> createState() => RopeScreenState();
}

class RopeScreenState extends State<RopeScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.rope);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.rope.name));
      }
    });
  }

  void _tap(int? knot) {
    if (knot == null || play.isOver) return;
    setState(() {
      play = play.tap(knot);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.rope.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.rope.name);
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
      play = Play.of(widget.rope);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'lift' ? 'Lift the ringed peg: it is off the marking.' : 'Stand a peg on the ringed knot.';
    }
    final sides = play.sides;
    if (sides == null) {
      return 'Pegs ${play.marks.length} of 2 stand; tap a knot.';
    }
    final (a, b, c) = _ordered(sides);
    if (!play.closes) {
      return 'No triangle: $a + $b is not more than $c.';
    }
    final short = play.shortfall!;
    if (short == 0) return 'Square: ${a * a} + ${b * b} = ${c * c}.';
    return '${short > 0 ? 'Sharp' : 'Blunt'} corner: ${a * a} + ${b * b} is '
        '${a * a + b * b} against ${c * c}, ${short.abs()} ${short > 0 ? 'over' : 'short'}.';
  }

  /// The sides small to large.
  static (int, int, int) _ordered(Sides sides) => Rules.sorted(sides);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.rope.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap knots on the rope to stand the two pegs, tap a peg to '
                  'lift it; the third peg is home, where the ends meet: '
                  '${widget.rope.task}.',
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
                      painter: RopeView(
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
                      play.sides == null
                          ? 'pegs ${play.marks.length} of 2'
                          : 'sides ${_ordered(play.sides!).$1}, ${_ordered(play.sides!).$2}, ${_ordered(play.sides!).$3}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.sides != null && !play.isDone ? Palette.bad : Palette.line),
                    label: Text(
                      play.sides == null
                          ? 'squares waiting'
                          : 'squares ${_ordered(play.sides!).$1 * _ordered(play.sides!).$1} + '
                              '${_ordered(play.sides!).$2 * _ordered(play.sides!).$2} '
                              'against ${_ordered(play.sides!).$3 * _ordered(play.sides!).$3}',
                      style: TextStyle(
                          color: play.isDone ? Palette.good : Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'corner ${play.sides == null ? 'open' : !play.closes ? 'none' : play.shortfall == 0 ? 'square' : play.shortfall! > 0 ? 'sharp' : 'blunt'}',
                      style: const TextStyle(
                          color: Palette.peg, fontSize: 13),
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
