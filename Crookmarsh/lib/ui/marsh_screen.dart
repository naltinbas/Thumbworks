import 'package:flutter/material.dart';

import '../best.dart';
import '../marsh/setting.dart';
import '../marsh/play.dart';
import 'marshview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One marsh, set post by post.
class MarshScreen extends StatefulWidget {
  const MarshScreen({super.key, required this.marsh});

  final Setting marsh;

  @override
  State<MarshScreen> createState() => MarshScreenState();
}

class MarshScreenState extends State<MarshScreen> {
  late Play play;

  /// The crossing the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.marsh);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.marsh.name));
      }
    });
  }

  void _tap((int, int)? spot) {
    if (spot == null || play.isOver) return;
    final turned = play.tapAt(spot);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.marsh.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.marsh.name);
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
      play = Play.of(widget.marsh);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the marsh says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final lifting = play.posts.contains(aim);
      return lifting
          ? 'Lift the post ringed blue.'
          : 'Set a post on the ringed crossing.';
    }
    if (play.isDone) {
      return 'Standing: ${play.frames.length}, as asked.';
    }
    if (play.lined.isNotEmpty) {
      return 'Three posts share a line: lift one of them.';
    }
    if (!play.allSet) {
      final left = play.marsh.posts - play.posts.length;
      return '${play.posts.length} set, $left to go; '
          '${play.frames.length} '
          'frame${play.frames.length == 1 ? '' : 's'} so far.';
    }
    return '${play.frames.length} '
        'frame${play.frames.length == 1 ? '' : 's'} '
        'show${play.frames.length == 1 ? 's' : ''}; '
        '${play.marsh.asked} asked.';
  }

  @override
  Widget build(BuildContext context) {
    final aim = pointing;
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(widget.marsh.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap to set or lift: ${widget.marsh.task}.',
                style: const TextStyle(
                    color: Palette.inkDim, fontSize: 14),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, room) => GestureDetector(
                  onTapUp: (tap) => _tap(Metrics(
                    Size(room.maxWidth, room.maxHeight),
                  ).crossUnder(tap.localPosition)),
                  child: CustomPaint(
                    painter: MarshView(
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
                  side: const BorderSide(color: Palette.frame),
                  label: Text(
                    'frames ${play.frames.length}',
                    style: const TextStyle(
                        color: Palette.frame, fontSize: 13),
                  ),
                ),
                if (play.lined.isNotEmpty)
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.lined),
                    label: Text(
                      'lined ${play.lined.length}',
                      style: const TextStyle(
                          color: Palette.lined, fontSize: 13),
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
                  color: aim != null
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
                onMarsh: () => Navigator.of(context).pop(),
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
