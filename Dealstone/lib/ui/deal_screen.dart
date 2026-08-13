import 'package:flutter/material.dart';

import '../best.dart';
import '../deal/handful.dart';
import '../deal/play.dart';
import 'dealview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One handful, piled slot by slot.
class DealScreen extends StatefulWidget {
  const DealScreen({super.key, required this.handful});

  final Handful handful;

  @override
  State<DealScreen> createState() => DealScreenState();
}

class DealScreenState extends State<DealScreen> {
  late Play play;

  /// The slot the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.handful);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.handful.name));
      }
    });
  }

  void _tap(int slot) {
    if (slot < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(slot);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.handful.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.handful.name);
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
      play = Play.of(widget.handful);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the stone says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return play.pool > 0
          ? 'Drop a stone on the ringed slot.'
          : 'Sweep the ringed pile back to the pool.';
    }
    if (play.isDone) {
      return 'Dealt home: the road runs as asked.';
    }
    if (play.pool > 0) {
      return '${play.pool} stone${play.pool == 1 ? '' : 's'} in '
          'the pool; tap a pile or an empty slot.';
    }
    if (play.deals < 0) {
      return 'The deal never stops: '
          '${widget.handful.stones} stones hold no stair.';
    }
    return 'The road runs ${play.deals} '
        'deal${play.deals == 1 ? '' : 's'} where '
        '${widget.handful.asked} '
        '${widget.handful.asked == 1 ? 'is' : 'are'} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.handful.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a slot to drop a stone; with the pool '
                  'spent, tap a pile to sweep it back: '
                  '${widget.handful.task}.',
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
                    ).slotUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: DealView(
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
                            ? Palette.stair
                            : Palette.line),
                    label: Text(
                      play.pool > 0
                          ? 'pool ${play.pool}'
                          : play.deals < 0
                              ? 'no standstill'
                              : 'deals ${play.deals}, asked '
                                  '${widget.handful.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'hand ${play.piles.isEmpty ? 'bare' : play.piles.join(' · ')}',
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
                  onStone: () => Navigator.of(context).pop(),
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
