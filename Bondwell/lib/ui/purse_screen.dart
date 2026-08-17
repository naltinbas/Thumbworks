import 'package:flutter/material.dart';

import '../best.dart';
import '../bond/level.dart';
import '../bond/play.dart';
import '../bond/rules.dart';
import 'palette.dart';
import 'purseview.dart';
import 'result_card.dart';

/// One ask: the chest, the three purses and the scales between them.
class PurseScreen extends StatefulWidget {
  const PurseScreen({super.key, required this.level});

  final Level level;

  @override
  State<PurseScreen> createState() => PurseScreenState();
}

class PurseScreenState extends State<PurseScreen> {
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

  void _step(int which, int by) {
    if (play.isOver) return;
    final next = play.step(which, by);
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

  /// What the sham says of the division, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return Play.pointed(aim);
    final tilts = play.tilts;
    final out = <String>[];
    const pairs = [(0, 1), (1, 2), (2, 0)];
    for (var k = 0; k < pairs.length; k++) {
      if (tilts[k] == 0) continue;
      final (i, j) = pairs[k];
      final owed = tilts[k] < 0 ? Rules.names[i] : Rules.names[j];
      out.add('${Rules.names[i]} and ${Rules.names[j]} are '
          '${Rules.tellParts(tilts[k].abs())} out, $owed short');
    }
    final head = play.chest == 0
        ? 'The chest is empty and the purses hold ${play.purses.join(', ')}.'
        : 'The purses hold ${play.purses.join(', ')} with ${play.chest} '
            'left in the chest.';
    if (play.gaveUp) return '$head The scales will not have it.';
    if (out.isEmpty) {
      return play.isDone
          ? 'As asked. $head Every scale hangs level.'
          : '$head Every scale hangs level.';
    }
    return '$head ${out.join('; ')}.';
  }

  Widget _dial(int which) {
    Widget button(int by, IconData icon) {
      final lit = pointing == (which, by);
      return IconButton(
        key: Key('${Rules.names[which]}${by > 0 ? '+' : ''}$by'),
        onPressed: play.isOver ? null : () => _step(which, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 32),
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
        button(-3, Icons.keyboard_double_arrow_left),
        button(-1, Icons.remove),
        SizedBox(
          width: 52,
          child: Text(
            '${Rules.names[which]} ${play.purses[which]}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.ink, fontSize: 13),
          ),
        ),
        button(1, Icons.add),
        button(3, Icons.keyboard_double_arrow_right),
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
                  'Tap a purse to drop a coin in, or use the dials: '
                  '${widget.level.task}.',
                  style:
                      const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) {
                      final which =
                          Metrics(Size(room.maxWidth, room.maxHeight))
                              .under(tap.localPosition);
                      if (which != null) _step(which, 1);
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: PurseView(
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
                    spacing: 6,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < Rules.heirs; i++) _dial(i),
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
                        scalesChip(play),
                        style: const TextStyle(
                            color: Palette.gold, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'chest ${play.chest}',
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
