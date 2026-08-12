import 'package:flutter/material.dart';

import '../best.dart';
import '../wish/play.dart';
import '../wish/wish.dart';
import 'palette.dart';
import 'result_card.dart';
import 'wishview.dart';

/// One wish list, trodden path by path.
class WishScreen extends StatefulWidget {
  const WishScreen({super.key, required this.wish});

  final Wish wish;

  @override
  State<WishScreen> createState() => WishScreenState();
}

class WishScreenState extends State<WishScreen> {
  late Play play;

  /// The pair the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.wish);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.wish.name));
      }
    });
  }

  void _tap(int? pair) {
    if (pair == null || play.isOver) return;
    setState(() {
      play = play.flipAt(pair);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.wish.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.wish.name);
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
      play = Play.of(widget.wish);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the green says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return play.trodden[aim]
          ? 'Lift the ringed path; the landing does without it.'
          : 'Tread the ringed path.';
    }
    if (play.isDone) {
      return 'Landed: every farm holds exactly its wish.';
    }
    final counts = play.counts;
    var met = 0;
    for (var farm = 0; farm < widget.wish.farms; farm++) {
      if (counts[farm] == widget.wish.wishes[farm]) met++;
    }
    return '$met farm${met == 1 ? '' : 's'} of '
        '${widget.wish.farms} hold${met == 1 ? 's' : ''} '
        'the wish.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.wish.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap the line between two farms to tread or '
                  'lift the path: ${widget.wish.task}.',
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
                    ).pairUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: WishView(
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
                    side: BorderSide(
                        color: play.isDone
                            ? Palette.wishGold
                            : Palette.line),
                    label: Text(
                      'paths ${play.paths}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'wish sum ${widget.wish.wishes.reduce((a, b) => a + b)}, so ${widget.wish.wishes.reduce((a, b) => a + b) ~/ 2} paths',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
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
                  onGreen: () => Navigator.of(context).pop(),
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
