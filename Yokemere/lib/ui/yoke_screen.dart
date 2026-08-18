import 'package:flutter/material.dart';

import '../best.dart';
import '../yoke/level.dart';
import '../yoke/play.dart';
import '../yoke/rules.dart';
import 'palette.dart';
import 'result_card.dart';
import 'yokeview.dart';

/// One ask, the yard laid to it.
class YokeScreen extends StatefulWidget {
  const YokeScreen({super.key, required this.level});

  final Level level;

  @override
  State<YokeScreen> createState() => YokeScreenState();
}

class YokeScreenState extends State<YokeScreen> {
  late Play play;

  /// The two places the show-me wants swapped, or null.
  (int, int)? pointing;

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

  void _tap(int place) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.tap(place);
      pointing = null;
      refused = null;
    });
    if (play.swaps == was.swaps) return;
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.swaps).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
          });
        }
      });
    }
  }

  void _miss() {
    if (play.isOver) return;
    setState(() {
      pointing = null;
      refused = 'Tap one place, then another, and the two off oxen change '
          'over.';
    });
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

  /// What the yard says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'The hardest any team here can pull is ${Rules.hardest()}, and '
          '${widget.level.pull} is past it.';
    }
    if (play.isDone) return 'As asked.';
    if (play.held != null) {
      return 'Place ${play.held! + 1} is in hand. Tap the place to change '
          'it over with.';
    }
    return play.anyCrossed
        ? 'The team pulls ${play.pull}, and some pairs are still crossed.'
        : 'The team pulls ${play.pull}, and nothing is crossed.';
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
                  'Tap two places to change their oxen over: '
                  '${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final place = Metrics(
                              play, Size(room.maxWidth, room.maxHeight))
                          .placeNear(touch.localPosition);
                      if (place != null) {
                        _tap(place);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: YokeView(
                        play: play,
                        pointing: pointing,
                        showCrossed: true,
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
                          color: play.pull == widget.level.pull
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        'pull ${play.pull} of ${widget.level.pull}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.anyCrossed
                              ? Palette.line
                              : Palette.good),
                      label: Text(
                        play.anyCrossed ? 'crossed' : 'nothing crossed',
                        style: TextStyle(
                          color: play.anyCrossed
                              ? Palette.crossed
                              : Palette.matched,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'swaps ${play.swaps}',
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
                // The card runs long on a small phone, so it is given
                // room to scroll rather than pushing the buttons off.
                Flexible(
                  child: SingleChildScrollView(
                    child: ResultCard(
                      play: play,
                      fewest: fewest,
                      isRecord: isRecord,
                      onAgain: _again,
                      onYard: () => Navigator.of(context).pop(),
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
