import 'package:flutter/material.dart';

import '../best.dart';
import '../shake/lawn.dart';
import '../shake/play.dart';
import 'lawnview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One lawn, greeted guest by guest.
class LawnScreen extends StatefulWidget {
  const LawnScreen({super.key, required this.fete});

  final Lawn fete;

  @override
  State<LawnScreen> createState() => LawnScreenState();
}

class LawnScreenState extends State<LawnScreen> {
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
    play = Play.of(widget.fete);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.fete.name));
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
      Best.landed(widget.fete.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.fete.name);
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
      play = Play.of(widget.fete);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the lawn says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final ((a, b), shake) = aim;
      return shake
          ? 'Shake guests ${a + 1} and ${b + 1} together.'
          : 'Unshake guests ${a + 1} and ${b + 1}.';
    }
    if (play.isDone) {
      return 'Greeted: ${play.oddHanded.length} odd-handed, '
          'as asked.';
    }
    if (play.picked != null) {
      return 'Guest ${play.picked! + 1} offers a hand; tap '
          'another guest.';
    }
    return '${play.oddHanded.length} odd-handed of '
        '${play.fete.guests}; ${play.fete.asked} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.fete.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two guests to shake hands, or a shaken '
                  'pair to unshake: ${widget.fete.task}.',
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
                    ).guestUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: LawnView(
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
                    side: const BorderSide(color: Palette.shake),
                    label: Text(
                      'shakes ${play.shakes.length}',
                      style: const TextStyle(
                          color: Palette.shake, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.odd),
                    label: Text(
                      'odd-handed ${play.oddHanded.length}',
                      style: const TextStyle(
                          color: Palette.odd, fontSize: 13),
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
                  onFete: () => Navigator.of(context).pop(),
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
