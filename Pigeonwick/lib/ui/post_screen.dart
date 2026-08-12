import 'package:flutter/material.dart';

import '../best.dart';
import '../post/play.dart';
import '../post/round.dart';
import 'palette.dart';
import 'postview.dart';
import 'result_card.dart';

/// One round, posted letter by letter.
class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.round});

  final Round round;

  @override
  State<PostScreen> createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  late Play play;

  /// The letter and hole the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.round);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.round.name));
      }
    });
  }

  void _turn(Play turned) {
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.round.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.round.name);
          });
        }
      });
    }
  }

  void _tap(Offset at, Size room) {
    if (play.isOver) return;
    final metrics = Metrics(play, room);
    final hole = metrics.holeUnder(at);
    if (hole >= 0) {
      _turn(play.tapHole(hole));
      return;
    }
    final letter = metrics.letterUnder(at);
    if (letter >= 0) {
      _turn(play.tapLetter(letter));
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
      play = Play.of(widget.round);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the round says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Post letter ${aim.$1 + 1} to hole ${aim.$2 + 1}.';
    }
    if (play.isDone) {
      return 'Posted: ${play.homes.length} home, as asked.';
    }
    if (play.held != null) {
      return 'Letter ${play.held! + 1} in hand; tap a hole.';
    }
    if (play.homes.isNotEmpty) {
      final home =
          play.homes.map((letter) => '${letter + 1}').join(' and ');
      return 'Letter${play.homes.length == 1 ? '' : 's'} $home '
          'sit${play.homes.length == 1 ? 's' : ''} home.';
    }
    final left =
        play.posting.where((hole) => hole < 0).length;
    return left == 0
        ? 'All posted; none home.'
        : '$left letter${left == 1 ? '' : 's'} in the bag.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.round.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a letter, then a hole: '
                  '${widget.round.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(tap.localPosition,
                        Size(room.maxWidth, room.maxHeight)),
                    child: CustomPaint(
                      painter: PostView(
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
                    side: const BorderSide(color: Palette.paper),
                    label: Text(
                      'posted '
                      '${play.posting.where((hole) => hole >= 0).length} '
                      'of ${play.round.letters}',
                      style: const TextStyle(
                          color: Palette.paper, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.home),
                    label: Text(
                      'home ${play.homes.length}',
                      style: const TextStyle(
                          color: Palette.home, fontSize: 13),
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
                  onWick: () => Navigator.of(context).pop(),
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
