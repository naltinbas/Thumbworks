import 'package:flutter/material.dart';

import '../best.dart';
import '../mark/low.dart';
import '../mark/play.dart';
import 'lowview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One low, marked post by post.
class LowScreen extends StatefulWidget {
  const LowScreen({super.key, required this.low});

  final Low low;

  @override
  State<LowScreen> createState() => LowScreenState();
}

class LowScreenState extends State<LowScreen> {
  late Play play;

  /// The post and mark the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.low);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.low.name));
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
      Best.landed(widget.low.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.low.name);
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
      play = Play.of(widget.low);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the low says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Mark post ${aim.$1 + 1} with ${aim.$2}.';
    }
    if (play.isDone) {
      return 'Graced: the gaps run 1 to '
          '${play.low.lines.length}.';
    }
    if (play.clashes.isNotEmpty) {
      return 'Two posts share a mark: renumber one.';
    }
    if (play.repeats.isNotEmpty) {
      return 'Two lines wear the same gap: renumber an end.';
    }
    final bare =
        play.numbering.where((mark) => mark < 0).length;
    return bare > 0
        ? '$bare post${bare == 1 ? '' : 's'} still bare.'
        : 'All marked; the gaps must run 1 to '
            '${play.low.lines.length}.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.low.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a post to cycle its mark: '
                  '${widget.low.task}.',
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
                      painter: LowView(
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
                    side: const BorderSide(color: Palette.gap),
                    label: Text(
                      'gaps '
                      '${play.gaps.where((gap) => gap >= 0).length} '
                      'of ${play.low.lines.length}',
                      style: const TextStyle(
                          color: Palette.gap, fontSize: 13),
                    ),
                  ),
                  if (play.clashes.isNotEmpty ||
                      play.repeats.isNotEmpty)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.clash),
                      label: Text(
                        'doubles '
                        '${play.clashes.length + play.repeats.length}',
                        style: const TextStyle(
                            color: Palette.clash, fontSize: 13),
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
                  onLow: () => Navigator.of(context).pop(),
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
