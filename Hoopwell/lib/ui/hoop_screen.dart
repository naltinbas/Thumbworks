import 'package:flutter/material.dart';

import '../best.dart';
import '../hoop/level.dart';
import '../hoop/play.dart';
import 'hoopview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the hoop laid to it.
class HoopScreen extends StatefulWidget {
  const HoopScreen({super.key, required this.level});

  final Level level;

  @override
  State<HoopScreen> createState() => HoopScreenState();
}

class HoopScreenState extends State<HoopScreen> {
  late Play play;

  /// The stone the show-me points at, as a ring and a hole, or null.
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

  void _tap((int, int) stone) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.tap(stone.$1, stone.$2);
      pointing = null;
      refused = null;
    });
    if (identical(play, was)) return;
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

  void _miss() {
    if (play.isOver) return;
    setState(() {
      pointing = null;
      refused = 'The lamps are not tapped. Tap an inner or middle hole to '
          'put a stone in it or take one out.';
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

  /// What the hoop says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      final asked = shown;
      final runs = asked.runEnds.length;
      return 'With the stones the ask calls for, stepping by ${asked.step} '
          'passes through every hole, so the pale stones fall into $runs '
          '${runs == 1 ? 'run' : 'runs'} and the hole past each run lights '
          'as well.';
    }
    if (play.isDone) return 'As asked.';
    if (play.darkCount == 0 || play.paleCount == 0) {
      return 'A ring with no stones lights nothing at all.';
    }
    return '${play.lampCount} lamps lit, and the floor for ${play.darkCount} '
        'and ${play.paleCount} stones is ${play.floor}.';
  }

  /// What the board draws. Once a hopeless ask has been admitted it
  /// shows the nearest board carrying the stones the ask asked for,
  /// since that is the board the walk and the card are talking about.
  Play get shown => play.gaveUp ? play.asAsked : play;

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
                  'Tap a hole to lay a stone or lift it: '
                  '${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final stone = Metrics(
                              play, Size(room.maxWidth, room.maxHeight))
                          .stoneNear(touch.localPosition);
                      if (stone != null) {
                        _tap(stone);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: HoopView(
                        play: shown,
                        pointing: pointing,
                        showWhyNot: play.gaveUp,
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
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'stones ${play.darkCount} and ${play.paleCount}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.lampCount == widget.level.lit
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        'lamps ${play.lampCount} of ${widget.level.lit}',
                        style: TextStyle(
                          color: play.lampCount == widget.level.lit
                              ? Palette.good
                              : Palette.lit,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'taps ${play.taps}',
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
                      onHoop: () => Navigator.of(context).pop(),
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
