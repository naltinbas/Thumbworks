import 'package:flutter/material.dart';

import '../basket/fen.dart';
import '../basket/play.dart';
import '../best.dart';
import 'fenview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One fen, picked basket by basket.
class FenScreen extends StatefulWidget {
  const FenScreen({super.key, required this.fen});

  final Fen fen;

  @override
  State<FenScreen> createState() => FenScreenState();
}

class FenScreenState extends State<FenScreen> {
  late Play play;

  /// The basket the show-me points at, or null.
  (int, bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.fen);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.fen.name));
      }
    });
  }

  void _tap(int basket) {
    if (basket < 0 || play.isOver) return;
    final turned = play.tapAt(basket);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.fen.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.fen.name);
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
      play = Play.of(widget.fen);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the fen says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$2
          ? 'Take the ringed basket.'
          : 'Hand the ringed basket back.';
    }
    if (play.isDone) {
      return 'Taken: ${play.fen.take} baskets, all free.';
    }
    if (play.swallowings.isNotEmpty) {
      return 'One taken basket swallows another: hand one back.';
    }
    final left = play.fen.take - play.taken.length;
    return '${play.taken.length} taken, $left to go; all free '
        'so far.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.fen.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a basket to take it or hand it back: '
                  '${widget.fen.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(Metrics(
                      Size(room.maxWidth, room.maxHeight),
                    ).basketUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: FenView(
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
                    side: const BorderSide(color: Palette.taken),
                    label: Text(
                      'taken ${play.taken.length} of '
                      '${play.fen.take}',
                      style: const TextStyle(
                          color: Palette.taken, fontSize: 13),
                    ),
                  ),
                  if (play.swallowings.isNotEmpty)
                    Chip(
                      backgroundColor: Palette.board,
                      side:
                          const BorderSide(color: Palette.swallow),
                      label: Text(
                        'swallowings ${play.swallowings.length}',
                        style: const TextStyle(
                            color: Palette.swallow, fontSize: 13),
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
                  onFen: () => Navigator.of(context).pop(),
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
