import 'package:flutter/material.dart';

import '../best.dart';
import '../third/hand.dart';
import '../third/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'thirdview.dart';

/// One hand, dialled stone by stone.
class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key, required this.hand});

  final Hand hand;

  @override
  State<ThirdScreen> createState() => ThirdScreenState();
}

class ThirdScreenState extends State<ThirdScreen> {
  late Play play;

  /// The stone the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.hand);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.hand.name));
      }
    });
  }

  void _tap(int stone) {
    if (stone < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(stone);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.hand.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.hand.name);
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
      play = Play.of(widget.hand);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// The remainder tally, nought-one-two.
  String tally() {
    final counts = [0, 0, 0];
    for (final face in play.faces) {
      counts[face % 3]++;
    }
    return counts.join('-');
  }

  /// What the leton says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Tap the ringed stone round to its next face.';
    }
    if (play.isDone) {
      return 'Dialled home: exactly ${play.thirds.length} '
          'third${play.thirds.length == 1 ? '' : 's'}, as asked.';
    }
    final held = play.thirds.length;
    return '$held third${held == 1 ? ' stands' : 's stand'} '
        'where ${widget.hand.asked} '
        '${widget.hand.asked == 1 ? 'is' : 'are'} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.hand.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a stone to turn its face one up: '
                  '${widget.hand.task}.',
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
                    ).stoneUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: ThirdView(
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
                            ? Palette.good
                            : Palette.line),
                    label: Text(
                      'thirds ${play.thirds.length}, asked '
                      '${widget.hand.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'remainders ${tally()}',
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
                  onLeton: () => Navigator.of(context).pop(),
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
