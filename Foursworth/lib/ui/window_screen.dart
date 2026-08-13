import 'package:flutter/material.dart';

import '../best.dart';
import '../window/house.dart';
import '../window/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'windowview.dart';

/// One house, dialled window by window.
class WindowScreen extends StatefulWidget {
  const WindowScreen({super.key, required this.house});

  final House house;

  @override
  State<WindowScreen> createState() => WindowScreenState();
}

class WindowScreenState extends State<WindowScreen> {
  late Play play;

  /// The window the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.house);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.house.name));
      }
    });
  }

  void _tap(int window) {
    if (window < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(window);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.house.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.house.name);
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
      play = Play.of(widget.house);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the worth says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Tap the ringed window round toward a landing.';
    }
    if (play.isDone) {
      return 'Dark as asked: the road runs ${play.turns} '
          'turn${play.turns == 1 ? '' : 's'}.';
    }
    if (play.turns < 0) {
      return 'This dialling circles for ever.';
    }
    return 'The road runs ${play.turns} '
        'turn${play.turns == 1 ? '' : 's'} where '
        '${widget.house.asked} ${widget.house.asked == 1 ? 'is' : 'are'} '
        'asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.house.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a window to turn its face one up; the '
                  'house walks its road below: '
                  '${widget.house.task}.',
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
                    ).windowUnder(tap.localPosition)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: WindowView(
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
                            ? Palette.rest
                            : Palette.line),
                    label: Text(
                      play.turns < 0
                          ? 'circling'
                          : 'turns ${play.turns}, asked '
                              '${widget.house.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'windows ${play.windows.join(' · ')}',
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
                  onWorth: () => Navigator.of(context).pop(),
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
