import 'package:flutter/material.dart';

import '../best.dart';
import '../fold/fold.dart';
import '../fold/play.dart';
import 'foldview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One paddock, folded hurdle by hurdle.
class FoldScreen extends StatefulWidget {
  const FoldScreen({super.key, required this.fold});

  final Fold fold;

  @override
  State<FoldScreen> createState() => FoldScreenState();
}

class FoldScreenState extends State<FoldScreen> {
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
    play = Play.of(widget.fold);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.fold.name));
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
      Best.landed(widget.fold.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.fold.name);
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
      play = Play.of(widget.fold);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the paddock says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final ((a, b), lay) = aim;
      return lay
          ? 'Lay a hurdle from post ${a + 1} to post ${b + 1}.'
          : 'Lift the hurdle from post ${a + 1} to post ${b + 1}.';
    }
    if (play.isDone) {
      return 'Folded: ${play.ears.length} '
          'ear${play.ears.length == 1 ? '' : 's'} lit.';
    }
    if (play.crossings.isNotEmpty) {
      return 'Two hurdles cross: lift one.';
    }
    if (play.picked != null) {
      return 'Post ${play.picked! + 1} picked; tap a post two or '
          'more away.';
    }
    if (play.fenced) {
      return 'Folded, but the crowns miss the asking: lift and '
          'relay.';
    }
    final left = play.fold.posts - 3 - play.hurdles.length;
    return '${play.hurdles.length} laid, $left to go.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.fold.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two posts to lay a hurdle, or a laid '
                  'pair to lift it: ${widget.fold.task}.',
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
                      painter: FoldView(
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
                    side: const BorderSide(color: Palette.hurdle),
                    label: Text(
                      'hurdles ${play.hurdles.length} of '
                      '${play.fold.posts - 3}',
                      style: const TextStyle(
                          color: Palette.hurdle, fontSize: 13),
                    ),
                  ),
                  if (play.fenced)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.ear),
                      label: Text(
                        'ears ${play.ears.length}',
                        style: const TextStyle(
                            color: Palette.ear, fontSize: 13),
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
                  onLeigh: () => Navigator.of(context).pop(),
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
