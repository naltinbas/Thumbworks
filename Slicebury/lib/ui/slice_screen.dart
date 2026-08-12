import 'package:flutter/material.dart';

import '../best.dart';
import '../slice/cake.dart';
import '../slice/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'sliceview.dart';

/// One cake, set candle by candle.
class SliceScreen extends StatefulWidget {
  const SliceScreen({super.key, required this.cake});

  final Cake cake;

  @override
  State<SliceScreen> createState() => SliceScreenState();
}

class SliceScreenState extends State<SliceScreen> {
  late Play play;

  /// The spot the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.cake);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.cake.name));
      }
    });
  }

  void _tap(int spot) {
    if (spot < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(spot);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.cake.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.cake.name);
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
      play = Play.of(widget.cake);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the bury says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return play.picked.contains(pointing)
          ? 'Lift the ringed candle; the landing does without it.'
          : 'Set a candle at the ringed spot.';
    }
    if (play.isDone) {
      return 'Cut true: exactly ${play.slices} slices, as asked.';
    }
    if (play.picked.length < widget.cake.candles) {
      return 'Candles ${play.picked.length} of '
          '${widget.cake.candles} set; the knife cuts '
          '${play.slices} slice${play.slices == 1 ? '' : 's'}.';
    }
    return 'All candles set, but the knife cuts ${play.slices} '
        'where ${widget.cake.slices} ${widget.cake.slices == 1 ? 'is' : 'are'} '
        'asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.cake.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a rim spot to set or lift a candle; the '
                  'knife joins every pair: ${widget.cake.task}.',
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
                    ).spotUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: SliceView(
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
                      'slices ${play.slices}, asked '
                      '${widget.cake.slices}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'candles ${play.picked.length} of '
                      '${widget.cake.candles}',
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
                  onBury: () => Navigator.of(context).pop(),
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
