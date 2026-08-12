import 'package:flutter/material.dart';

import '../best.dart';
import '../hoard/hoard.dart';
import '../hoard/play.dart';
import '../hoard/rules.dart';
import 'hoardview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One hoard, dialled tile by tile.
class HoardScreen extends StatefulWidget {
  const HoardScreen({super.key, required this.hoard});

  final Hoard hoard;

  @override
  State<HoardScreen> createState() => HoardScreenState();
}

class HoardScreenState extends State<HoardScreen> {
  late Play play;

  /// The turn the show-me points at, or null.
  (bool, bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.hoard);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.hoard.name));
      }
    });
  }

  void _turn(bool first, int by) {
    if (play.isOver) return;
    setState(() {
      play = first ? play.turnA(by) : play.turnB(by);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.hoard.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.hoard.name);
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
      play = Play.of(widget.hoard);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the holt says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final (first, up) = aim;
      return '${up ? 'Grow' : 'Shrink'} the '
          '${first ? 'copper' : 'slate'} tile.';
    }
    if (play.isDone) {
      return 'Paid: the tiles land the hoard exactly.';
    }
    final short = widget.hoard.target - play.paid;
    if (short > 0) {
      return 'The tiles pay ${play.paid}, $short short.';
    }
    return 'The tiles pay ${play.paid}, ${-short} over.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.hoard.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Turn the dials to grow or shrink each tile: '
                  '${widget.hoard.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: HoardView(
                    play: play,
                    pointing: pointing,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone
                            ? Palette.paidGold
                            : Palette.line),
                    label: Text(
                      'hoard ${widget.hoard.target}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      '${Rules.pastFours(widget.hoard.target)} past '
                      'the fours',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
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
                  onHolt: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final (label, first, by) in const [
                      ('copper −', true, -1),
                      ('copper +', true, 1),
                      ('slate −', false, -1),
                      ('slate +', false, 1),
                    ])
                      OutlinedButton(
                        onPressed:
                            play.isOver ? null : () => _turn(first, by),
                        child: Text(label),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
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
