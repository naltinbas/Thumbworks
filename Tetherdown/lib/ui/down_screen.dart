import 'package:flutter/material.dart';

import '../best.dart';
import '../down/down.dart';
import '../down/play.dart';
import 'downview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One down, roped post to post.
class DownScreen extends StatefulWidget {
  const DownScreen({super.key, required this.down});

  final Down down;

  @override
  State<DownScreen> createState() => DownScreenState();
}

class DownScreenState extends State<DownScreen> {
  late Play play;

  /// The rope the show-me points at, or null, with whether it
  /// wants tying.
  ((int, int), bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.down);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.down.name));
      }
    });
  }

  void _tap(int post) {
    if (post < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(post);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.down.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.down.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null && play.picked == null) return;
    setState(() {
      play = play.picked != null ? play.tapAt(play.picked!) : play.back;
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
      play = Play.of(widget.down);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the down says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final ((a, b), tie) = aim;
      return tie
          ? 'Rope posts ${a + 1} and ${b + 1}.'
          : 'Untie posts ${a + 1} and ${b + 1}.';
    }
    if (play.isDone) {
      return 'Tethered: ${play.down.asked} ropes, not a knot.';
    }
    if (play.knotted.isNotEmpty) {
      final (a, b, c) = play.knotted.first;
      return 'Posts ${a + 1}, ${b + 1} and ${c + 1} knot a '
          'triangle: untie a side.';
    }
    if (play.picked != null) {
      return 'Picked post ${play.picked! + 1}; tap another to '
          'rope them.';
    }
    final left = play.down.asked - play.ropes.length;
    return '${play.ropes.length} tied, $left to go; nothing '
        'knotted.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.down.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two posts to rope them, or the two ends of '
                  'a rope to untie it: ${widget.down.task}.',
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
                    ).postUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: DownView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.rope),
                    label: Text(
                      'ropes ${play.ropes.length} of '
                      '${play.down.asked}',
                      style: const TextStyle(
                          color: Palette.rope, fontSize: 13),
                    ),
                  ),
                  if (play.knotted.isNotEmpty)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.knot),
                      label: Text(
                        'knots ${play.knotted.length}',
                        style: const TextStyle(
                            color: Palette.knot, fontSize: 13),
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
                  onDown: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: play.before == null &&
                              play.picked == null
                          ? null
                          : _back,
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
