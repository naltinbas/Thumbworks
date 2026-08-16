import 'package:flutter/material.dart';

import '../best.dart';
import '../lever/frac.dart';
import '../lever/level.dart';
import '../lever/play.dart';
import '../lever/rules.dart';
import 'leverview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask: the loop of levers, and what the purse does when it is run.
class LeverScreen extends StatefulWidget {
  const LeverScreen({super.key, required this.level});

  final Level level;

  @override
  State<LeverScreen> createState() => LeverScreenState();
}

class LeverScreenState extends State<LeverScreen> {
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

  void _flip(int? slot) {
    if (slot == null || play.isOver) return;
    _after(play.flip(slot));
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

  /// What the sham says of the loop, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return Play.pointed(aim);
    final head = 'The loop ${Rules.tellLoop(play.loop)}: '
        '${play.climb == Frac.zero ? 'the purse gains nothing in the long run' : 'the purse climbs ${play.climb} of a coin a round'}, '
        'and after ${Play.rounds} rounds it is at '
        '${play.purse.last.toDouble.toStringAsFixed(3)}.';
    if (play.gaveUp) return '$head Two levers are needed, not one.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _slotButton(String label, IconData icon, VoidCallback? onTap, String key) =>
      IconButton(
        key: Key(key),
        onPressed: onTap,
        icon: Icon(icon,
            color: onTap == null ? Palette.line : Palette.ink, size: 20),
        tooltip: label,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          side: const BorderSide(color: Palette.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

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
                  'Tap a slot to turn its lever over, and the buttons to make '
                  'the loop longer or shorter: ${widget.level.task}.',
                  style:
                      const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _flip(
                      Metrics(play, Size(room.maxWidth, room.maxHeight))
                          .under(tap.localPosition),
                    ),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: LeverView(
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    _slotButton(
                      'Shorter',
                      Icons.remove,
                      play.loop.length <= Rules.least
                          ? null
                          : () => _after(play.shorter),
                      'shorter',
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        '${play.loop.length} slot${play.loop.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    _slotButton(
                      'Longer',
                      Icons.add,
                      play.loop.length >= Rules.most
                          ? null
                          : () => _after(play.longer),
                      'longer',
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.isDone ? Palette.good : Palette.line),
                      label: Text(
                        climbChip(play),
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
