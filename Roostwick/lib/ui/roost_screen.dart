import 'package:flutter/material.dart';

import '../best.dart';
import '../roost/level.dart';
import '../roost/play.dart';
import '../roost/rules.dart';
import 'palette.dart';
import 'result_card.dart';
import 'roostview.dart';

/// One ask, the wood laid to it.
class RoostScreen extends StatefulWidget {
  const RoostScreen({super.key, required this.level});

  final Level level;

  @override
  State<RoostScreen> createState() => RoostScreenState();
}

class RoostScreenState extends State<RoostScreen> {
  late Play play;

  /// The bird the show-me points at, or null.
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

  void _tap(int bird) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.tap(bird);
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
      refused = 'A hollow does not move. Tap a bird to send it along its '
          'tether to its other hollow.';
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

  /// What the wood says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      final jam = play.overfull.map(Rules.letter).join(' and ');
      return '${play.penned.length} birds have both of their hollows among '
          '$jam, and there are only ${play.overfull.length} of those.';
    }
    if (play.isDone) return 'As asked. Every bird in a hollow of its own.';
    final crowded = play.crowded;
    if (crowded.isEmpty) return 'Every bird in a hollow of its own.';
    return 'Crowded: ${crowded.map(Rules.letter).join(', ')}.';
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
                  'Tap a bird to send it along its tether: '
                  '${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final bird = Metrics(
                              play, Size(room.maxWidth, room.maxHeight))
                          .birdNear(touch.localPosition);
                      if (bird != null) {
                        _tap(bird);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: RoostView(
                        play: play,
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
                      side: BorderSide(
                          color: play.crowded.isEmpty
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        'crowded ${play.crowded.length}',
                        style: TextStyle(
                          color: play.crowded.isEmpty
                              ? Palette.alone
                              : Palette.crowd,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'settles ${widget.level.ways} of '
                        '${widget.level.seatings}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
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
                            ? Palette.crowd
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
                      onWood: () => Navigator.of(context).pop(),
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
