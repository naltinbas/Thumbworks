import 'package:flutter/material.dart';

import '../best.dart';
import '../miu/level.dart';
import '../miu/play.dart';
import '../miu/rules.dart';
import 'sheetview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One string, derived step by step.
class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key, required this.level});

  final Level level;

  @override
  State<SheetScreen> createState() => SheetScreenState();
}

class SheetScreenState extends State<SheetScreen> {
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

  void _tap(int? letter) {
    if (letter == null || play.isOver) return;
    _become(play.tap(letter));
  }

  void _rule(int rule) {
    if (play.isOver) return;
    _become(play.make((rule, 0)));
  }

  void _become(Play next) {
    setState(() {
      play = next;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.steps).then((record) {
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
            Text(
              whyWords(play),
              style: const TextStyle(
                color: Palette.ink,
                fontSize: 14,
                height: 1.5,
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
    if (aim != null) return 'Next: ${Rules.describe(aim)}.';
    if (play.isDone) {
      return 'Derived: ${play.level.target} in ${play.steps} step${play.steps == 1 ? '' : 's'}.';
    }
    if (play.missed) {
      return play.stuck
          ? 'No rule applies to ${play.string} on the sheet: a dead end.'
          : '${play.steps} steps spent, and the string is ${play.string}.';
    }
    if (play.gaveUp) {
      return play.stuck
          ? 'No rule applies to ${play.string} on the sheet, and MU never comes.'
          : 'Twelve steps, and the count of I never a multiple of three.';
    }
    return '${play.string}: ${play.iCount} I, leaving ${play.iCount % 3} by three; ${play.moves.length} move${play.moves.length == 1 ? '' : 's'} apply.';
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
              'The buttons for rules I and II, and a tap on the first '
              'letter of an III or a UU for rules III and IV: '
              '${widget.level.task}.',
              style: const TextStyle(color: Palette.inkDim, fontSize: 14),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, room) => GestureDetector(
                onTapUp: (tap) => _tap(
                  Metrics(
                    play,
                    Size(room.maxWidth, room.maxHeight),
                  ).under(tap.localPosition),
                ),
                child: CustomPaint(
                  key: const Key('board'),
                  painter: SheetView(
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
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: play.isOver || !play.moves.contains((1, 0))
                        ? null
                        : () => _rule(1),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Rule I: add U'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: play.isOver || !play.moves.contains((2, 0))
                        ? null
                        : () => _rule(2),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Rule II: double'),
                  ),
                ],
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
                  color: play.isDone
                      ? Palette.good
                      : play.spent && !play.isDone
                      ? Palette.bad
                      : Palette.line,
                ),
                label: Text(
                  'steps ${play.steps} of ${widget.level.steps}',
                  style: const TextStyle(color: Palette.ink, fontSize: 13),
                ),
              ),
              Chip(
                backgroundColor: Palette.board,
                side: const BorderSide(color: Palette.line),
                label: Text(
                  'letters ${play.string.length} of ${Rules.longest}',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 13),
                ),
              ),
              Chip(
                backgroundColor: Palette.board,
                side: const BorderSide(color: Palette.line),
                label: Text(
                  'I count ${play.iCount}',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 13),
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
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
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
                TextButton(onPressed: _why, child: const Text('Why')),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
