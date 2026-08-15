import 'package:flutter/material.dart';

import '../best.dart';
import '../pieces/geometry.dart';
import '../pieces/level.dart';
import '../pieces/play.dart';
import 'frameview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One frame, laid piece by piece.
class FrameScreen extends StatefulWidget {
  const FrameScreen({super.key, required this.level});

  final Level level;

  @override
  State<FrameScreen> createState() => FrameScreenState();
}

class FrameScreenState extends State<FrameScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.level);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.level.name));
      }
    });
  }

  void _tap(Offset at, Size room) {
    if (play.isOver) return;
    final m = Metrics(play, room);
    setState(() {
      pointing = null;
      final slot = m.slotUnder(at);
      if (slot != null) {
        play = play.hold(slot);
        return;
      }
      if (play.held == null) {
        final laid = m.laidUnder(at);
        if (laid != null) play = play.hold(laid);
        return;
      }
      final square = m.squareUnder(at);
      if (square != null) play = play.lay(square.$1, square.$2);
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
          });
        }
      });
    }
  }

  void _turn() {
    setState(() {
      play = play.turn;
      pointing = null;
    });
  }

  void _flip() {
    setState(() {
      play = play.flip;
      pointing = null;
    });
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
    setState(() {
      final aim = play.next;
      pointing = aim;
      if (aim != null && aim.$1 == 'lay') {
        // Take the piece up and turn it the aimed way, so the tap that
        // follows lays it.
        final target = Play.aimFor(widget.level)![aim.$2];
        if (play.held != aim.$2) play = play.hold(aim.$2);
        play = play.turnTo(aim.$2, (target.turn, target.flipped));
      }
    });
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
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'lay'
          ? 'Lay it with its corner on the ringed square, as the ghost shows.'
          : 'Lift the ringed piece; it is off the laying.';
    }
    if (play.isDone) return 'Laid: ${_overlapWords()} and ${_gapWords()}.';
    if (play.gaveUp) return 'The sliver stays: one square bare, and none can mend it.';
    if (play.overlaps.isNotEmpty) {
      return 'Pieces overlap by ${play.overlap} square${play.overlap == Q.one ? '' : 's'}, in rust.';
    }
    if (play.held != null) return 'A piece in hand: turn or flip it, then tap the square its corner goes on.';
    return 'Laid ${play.laidCount} of 4; tap a piece in the tray to take it up.';
  }

  String _overlapWords() => play.overlap.sign == 0 ? 'no overlap' : 'an overlap of ${play.overlap}';

  String _gapWords() => play.gap.sign == 0 ? 'no square bare' : '${play.gap} square bare';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.level.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a piece in the tray to take it up, turn or flip it, then '
                  'tap the square its lower left corner goes on; tap a laid '
                  'piece to take it up again; what two pieces share goes rust: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(tap.localPosition, Size(room.maxWidth, room.maxHeight)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: FrameView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: play.held == null || play.isOver ? null : _turn,
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Turn'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: play.held == null || play.isOver ? null : _flip,
                      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Flip'),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'laid ${play.laidCount} of 4',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.overlap2 > widget.level.overlapAllowed2 ? Palette.bad : Palette.line),
                    label: Text(
                      'overlap ${play.overlap}',
                      style: TextStyle(
                          color: play.overlap2 > widget.level.overlapAllowed2 ? Palette.bad : Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'bare ${play.gap}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
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
                  onSham: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
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
