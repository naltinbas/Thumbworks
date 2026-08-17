import 'package:flutter/material.dart';

import '../best.dart';
import '../hall/level.dart';
import '../hall/play.dart';
import '../hall/rules.dart';
import 'hallview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask: the field, the hall on its dials and the peg.
class HallScreen extends StatefulWidget {
  const HallScreen({super.key, required this.level});

  final Level level;

  @override
  State<HallScreen> createState() => HallScreenState();
}

class HallScreenState extends State<HallScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int, int)? pointing;

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

  void _after(Play next) {
    if (identical(next, play)) return;
    setState(() {
      play = next;
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

  void _stand((int, int)? point) {
    if (point == null || play.isOver) return;
    _after(play.stand(point.$1, point.$2));
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

  /// What the sham says of the standing, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return Play.pointed(aim);
    final head = 'A hall ${play.wide} by ${play.tall}, the peg at '
        '(${play.px}, ${play.py}): the posts are '
        '${Rules.tellSquares(play.squares)} paces off.';
    if (play.gaveUp) return '$head The lean keeps them apart.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _dial(String label, int which) {
    Widget button(int by, IconData icon) {
      final lit = pointing != null &&
          pointing!.$1 == (which == 0 ? 'wide' : 'tall') &&
          pointing!.$2 == by;
      return IconButton(
        key: Key('${which == 0 ? 'wide' : 'tall'}${by > 0 ? '+' : ''}$by'),
        onPressed: play.isOver
            ? null
            : () => _after(which == 0 ? play.stepWide(by) : play.stepTall(by)),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 34),
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
          width: 62,
          child: Text(
            '$label ${which == 0 ? play.wide : play.tall}',
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
                  'Tap a point to stand the peg there and the dials to change '
                  'the hall: ${widget.level.task}.',
                  style:
                      const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _stand(
                      Metrics(Size(room.maxWidth, room.maxHeight))
                          .under(tap.localPosition),
                    ),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: HallView(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [_dial('wide', 0), _dial('long', 1)],
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
                          color: play.agrees ? Palette.good : Palette.bad),
                      label: Text(
                        sumsChip(play),
                        style: const TextStyle(
                            color: Palette.gold, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        play.inside ? 'the peg is inside' : 'the peg is out',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
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
