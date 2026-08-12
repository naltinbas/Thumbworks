import 'package:flutter/material.dart';

import '../best.dart';
import '../peck/flock.dart';
import '../peck/play.dart';
import 'palette.dart';
import 'peckview.dart';
import 'result_card.dart';

/// One flock, settled flip by flip.
class PeckScreen extends StatefulWidget {
  const PeckScreen({super.key, required this.flock});

  final Flock flock;

  @override
  State<PeckScreen> createState() => PeckScreenState();
}

class PeckScreenState extends State<PeckScreen> {
  late Play play;

  /// The pair the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.flock);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.flock.name));
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
      Best.landed(widget.flock.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.flock.name);
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
      play = Play.of(widget.flock);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the yard says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Flip who pecks whom on the ringed pair.';
    }
    if (play.isDone) {
      return 'Crowned: exactly ${play.kings.length} '
          'king${play.kings.length == 1 ? '' : 's'}, both counts '
          'agreeing.';
    }
    final crowns = play.kings.length;
    return '$crowns crown${crowns == 1 ? ' stands' : 's stand'} '
        'where ${widget.flock.asked} '
        '${widget.flock.asked == 1 ? 'is' : 'are'} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.flock.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap an arrow to flip who pecks whom: '
                  '${widget.flock.task}.',
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
                      painter: PeckView(
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
                            ? Palette.crown
                            : Palette.line),
                    label: Text(
                      'crowns ${play.kings.length}, asked '
                      '${widget.flock.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.rosette),
                    label: Text(
                      'busiest pecks ${play.busiest.isEmpty ? 0 : play.outPecks[play.busiest.first]}',
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
                  onYard: () => Navigator.of(context).pop(),
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
