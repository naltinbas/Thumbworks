import 'package:flutter/material.dart';

import '../best.dart';
import '../comb/level.dart';
import '../comb/play.dart';
import '../comb/rules.dart';
import 'combview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One comb, filled number by number.
class CombScreen extends StatefulWidget {
  const CombScreen({super.key, required this.level});

  final Level level;

  @override
  State<CombScreen> createState() => CombScreenState();
}

class CombScreenState extends State<CombScreen> {
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

  void _tap(int? cell) {
    if (cell == null || play.isOver) return;
    setState(() {
      play = play.tap(cell);
      pointing = null;
    });
  }

  void _put(int v) {
    if (play.isOver) return;
    setState(() {
      play = play.put(v);
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
    setState(() {
      final aim = play.next;
      pointing = aim;
      // Pick the cell, so the number tapped next goes there.
      if (aim != null && aim.$1 == 'set' && play.held != aim.$2) play = play.tap(aim.$2);
    });
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
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'set' ? 'Put ${aim.$3} in the ringed cell.' : 'Clear the ringed cell; it is off the filling.';
    }
    if (play.isDone) return 'Filled: every line of the comb sums to ${play.rules.sum}.';
    if (play.gaveUp) return 'Full, and some line is off; no filling of the comb sums to ${play.rules.sum}.';
    final wrong = play.wrongLines.length;
    if (wrong > 0) return '$wrong line${wrong == 1 ? '' : 's'} complete and off, in rust.';
    if (play.held != null) return 'Cell picked: tap a number to put there.';
    return 'Filled ${play.filled} of ${Rules.cells}; tap an empty cell, then a number.';
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
                  'Tap an empty cell, then a number below to put there; tap a '
                  'cell you filled to clear it; a full line goes green when it '
                  'sums right and rust when it is off: ${widget.level.task}.',
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
                      painter: CombView(
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
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 0,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var v = 1; v <= Rules.cells; v++)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: TextButton(
                            onPressed: play.held == null || play.values.contains(v) ? null : () => _put(v),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(32, 32),
                              visualDensity: VisualDensity.compact,
                              foregroundColor: pointing != null && pointing!.$1 == 'set' && pointing!.$3 == v ? Palette.shown : Palette.honey,
                            ),
                            child: Text('$v', style: TextStyle(fontWeight: play.values.contains(v) ? FontWeight.w400 : FontWeight.w800)),
                          ),
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
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'filled ${play.filled} of ${Rules.cells}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.wrongLines.isEmpty ? Palette.line : Palette.bad),
                    label: Text(
                      'lines right ${play.rightLines.length} of ${Rules.lines.length}',
                      style: TextStyle(
                          color: play.wrongLines.isEmpty ? Palette.good : Palette.bad, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'sum ${widget.level.sum}',
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
