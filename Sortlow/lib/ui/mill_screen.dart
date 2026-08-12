import 'package:flutter/material.dart';

import '../best.dart';
import '../mill/load.dart';
import '../mill/play.dart';
import 'millview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One load, dialled digit by digit.
class MillScreen extends StatefulWidget {
  const MillScreen({super.key, required this.load});

  final Load load;

  @override
  State<MillScreen> createState() => MillScreenState();
}

class MillScreenState extends State<MillScreen> {
  late Play play;

  /// The dial the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.load);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.load.name));
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
      Best.landed(widget.load.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.load.name);
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
      play = Play.of(widget.load);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the low says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Tap the ringed dial round toward a landing.';
    }
    if (play.isDone) {
      return 'Dialled home: the road runs as asked.';
    }
    if (play.barred) {
      return 'All four digits alike: the mill bars the door.';
    }
    return 'The road runs ${play.steps} '
        'turn${play.steps == 1 ? '' : 's'} where '
        '${widget.load.asked} ${widget.load.asked == 1 ? 'is' : 'are'} '
        'asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.load.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a dial to turn its digit one up; the mill '
                  'grinds the road below: ${widget.load.task}.',
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
                    ).dialUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: MillView(
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
                            ? Palette.stone
                            : Palette.line),
                    label: Text(
                      play.barred
                          ? 'barred'
                          : 'turns ${play.steps}, asked '
                              '${widget.load.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'load ${play.number.toString().padLeft(4, '0')}',
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
