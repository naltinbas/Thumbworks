import 'package:flutter/material.dart';

import '../best.dart';
import '../plait/level.dart';
import '../plait/play.dart';
import '../plait/rules.dart';
import 'palette.dart';
import 'plaitview.dart';
import 'result_card.dart';

/// One ask, the plait hung for it.
class PlaitScreen extends StatefulWidget {
  const PlaitScreen({super.key, required this.level});

  final Level level;

  @override
  State<PlaitScreen> createState() => PlaitScreenState();
}

class PlaitScreenState extends State<PlaitScreen> {
  late Play play;

  /// The arc the show-me wants tapped, or null.
  int? pointing;

  /// What the last tap did, when it did nothing.
  String? refused;

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

  void _touch(Offset where, Size room) {
    if (play.isOver) return;
    final arc = Metrics(play, room).arcUnder(where);
    if (arc == null) {
      setState(() {
        pointing = null;
        refused = 'That is board, not rope. Tap a rope to dye it.';
      });
      return;
    }
    setState(() {
      play = play.tap(arc);
      pointing = null;
      refused = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.taps).then((record) {
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
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() {
      pointing = play.next;
      refused = null;
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
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the plait says of itself, as it stands.
  String verdict() {
    final arc = pointing;
    if (arc != null) return play.pointed(arc);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'Every painting that keeps the rule here is one colour.';
    }
    if (play.isDone) return 'As asked.';
    if (!play.allSound) {
      final n = play.wrong.length;
      return '$n crossing${n == 1 ? '' : 's'} still '
          '${n == 1 ? 'shows' : 'show'} two colours.';
    }
    return play.shades == 1
        ? 'The rule is kept, but one colour proves nothing.'
        : 'The rule is kept with ${play.shades} colours. Three are wanted.';
  }

  Widget _chip(String words, Color edge, Color ink) => Chip(
        backgroundColor: Palette.board,
        side: BorderSide(color: edge),
        label: Text(words, style: TextStyle(color: ink, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final right = level.word.length - play.wrong.length;
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(level.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap a rope to dye it: ${level.task}.',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, room) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (touch) => _touch(touch.localPosition,
                      Size(room.maxWidth, room.maxHeight)),
                  child: CustomPaint(
                    key: const Key('board'),
                    painter: PlaitView(
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
                  _chip(
                    'crossings $right of ${level.word.length}',
                    play.allSound ? Palette.good : Palette.line,
                    play.allSound ? Palette.good : Palette.ink,
                  ),
                  _chip(
                    'colours ${play.shades} of ${Rules.colours}',
                    play.shades == Rules.colours ? Palette.good : Palette.line,
                    Palette.ink,
                  ),
                  _chip('taps ${play.taps}', Palette.line, Palette.inkDim),
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
                      : refused != null
                          ? Palette.bad
                          : play.isDone
                              ? Palette.good
                              : Palette.ink,
                  fontSize: 14,
                ),
              ),
            ),
            if (play.isOver)
              // The card runs long on a small phone, so it is given room to
              // scroll rather than pushing the buttons off.
              Flexible(
                child: SingleChildScrollView(
                  child: ResultCard(
                    play: play,
                    fewest: fewest,
                    isRecord: isRecord,
                    onAgain: _again,
                    onWalk: () => Navigator.of(context).pop(),
                  ),
                ),
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
}
