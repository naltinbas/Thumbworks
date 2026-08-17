import 'package:flutter/material.dart';

import '../beat/level.dart';
import '../beat/play.dart';
import '../beat/rules.dart';
import '../best.dart';
import 'beatview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the ring laid to it.
class BeatScreen extends StatefulWidget {
  const BeatScreen({super.key, required this.level});

  final Level level;

  @override
  State<BeatScreen> createState() => BeatScreenState();
}

class BeatScreenState extends State<BeatScreen> {
  late Play play;

  /// The beat the show-me points at, or null.
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

  void _after(Play was) {
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

  void _take(int height) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.take(height);
      pointing = null;
      refused = null;
    });
    _after(was);
  }

  void _tap(int beat) {
    if (play.isOver) return;
    final was = play;
    final hand = play.held;
    setState(() {
      play = play.tap(beat);
      pointing = null;
      refused = null;
      if (identical(play, was)) {
        if (hand == null) {
          refused = 'Take a throw off the rack first.';
        } else {
          final at = Rules.lands(beat, hand);
          refused = 'A throw of $hand on beat $beat comes down on beat $at, '
              'where a ball comes down already.';
        }
      }
    });
    _after(was);
  }

  void _miss() {
    if (play.isOver) return;
    setState(() {
      pointing = null;
      refused = 'Tap a throw on the rack, then tap the beat to lay it on.';
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
      pointing = play.next?.$2;
      refused = play.next == null
          ? 'Nothing on the ring can be carried on with. Lift a throw off.'
          : null;
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

  /// What the ring says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null && play.next != null) return play.pointed(play.next!);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'The throws come to ${widget.level.total}, and '
          '${widget.level.total} into ${Rules.beats} will not go.';
    }
    if (play.isDone) return 'As asked.';
    if (play.held != null) {
      return 'A throw of ${play.held} in the hand. Tap the beat to lay it on.';
    }
    if (play.rack.isEmpty) return 'Every throw laid.';
    return '${play.rack.length} '
        '${play.rack.length == 1 ? 'throw' : 'throws'} still on the rack.';
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
                  'Take a throw and lay it on a beat: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final beat = Metrics(
                              play, Size(room.maxWidth, room.maxHeight))
                          .beatNear(touch.localPosition);
                      if (beat != null) {
                        _tap(beat);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: BeatView(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      // One chip a height, since a rack may hold two
                      // throws of the same one and two chips alike would
                      // be two names for one thing.
                      for (final h in play.rack.toSet().toList()..sort())
                        ActionChip(
                          key: Key('rack-$h'),
                          backgroundColor: Palette.board,
                          side: const BorderSide(color: Palette.line),
                          label: Text(
                            play.rack.where((t) => t == h).length > 1
                                ? '$h  x${play.rack.where((t) => t == h).length}'
                                : '$h',
                            style: const TextStyle(
                                color: Palette.tile,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => _take(h),
                        ),
                      if (play.held != null)
                        ActionChip(
                          key: const Key('in-hand'),
                          backgroundColor: Palette.tile,
                          side: const BorderSide(color: Palette.tile),
                          label: Text(
                            '${play.held}',
                            style: const TextStyle(
                                color: Palette.night,
                                fontSize: 15,
                                fontWeight: FontWeight.w800),
                          ),
                          onPressed: () => _take(play.held!),
                        ),
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
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'throws ${widget.level.total}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.isDone ? Palette.good : Palette.line),
                      label: Text(
                        'juggles ${widget.level.ways} of '
                        '${widget.level.layings}',
                        style: const TextStyle(
                            color: Palette.flight, fontSize: 13),
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
                      onRing: () => Navigator.of(context).pop(),
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
