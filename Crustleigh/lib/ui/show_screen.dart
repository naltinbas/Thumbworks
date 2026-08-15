import 'package:flutter/material.dart';

import '../best.dart';
import '../show/level.dart';
import '../show/play.dart';
import '../show/rules.dart';
import 'showview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One show, judged ballot by ballot.
class ShowScreen extends StatefulWidget {
  const ShowScreen({super.key, required this.level});

  final Level level;

  @override
  State<ShowScreen> createState() => ShowScreenState();
}

class ShowScreenState extends State<ShowScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (int, int)? pointing;

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

  void _tap((int, int)? touch) {
    if (touch == null || play.isOver) return;
    setState(() {
      play = play.tap(touch.$1, touch.$2);
      pointing = null;
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
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  whyWords(play),
                  style: const TextStyle(
                      color: Palette.ink, fontSize: 14, height: 1.5),
                ),
              ),
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
    if (aim != null) return 'Move ${Rules.pieNames[aim.$2]} up on ${ShowView.judgeNames[aim.$1]}\'s card.';
    final ring = play.ringOrder;
    if (ring != null) {
      final words = <String>[];
      for (var i = 0; i < ring.length; i++) {
        final a = ring[i], b = ring[(i + 1) % ring.length];
        words.add('${Rules.pieNames[a]} beats ${Rules.pieNames[b]} ${Rules.count(play.profile, a, b)} to ${Rules.judges - Rules.count(play.profile, a, b)}');
      }
      return '${play.isDone ? 'As asked: ' : ''}${_cap(words.join(', '))}: a ring.';
    }
    if (play.gaveUp) return 'Twenty-four moves, and the pie that beats both others somebody\'s first every time.';
    final w = play.winner;
    if (w == null) return 'No pie beats every other, and no ring runs round them all.';
    final pts = play.points;
    final firsts = Rules.firsts(play.profile).contains(w) ? 'somebody\'s first' : 'first on no ballot';
    final ahead = pts.where((x) => x > pts[w]).isEmpty ? 'and top on points' : 'but not top on points';
    return '${play.isDone ? 'As asked: ' : ''}${_cap(Rules.pieNames[w])} beats every other pie, $firsts, $ahead: ${pts[w]}.';
  }

  static String _cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

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
                  'Tap a pie to move it up its judge\'s card, the top one '
                  'round to the bottom: ${widget.level.task}.',
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
                    ).under(tap.localPosition)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: ShowView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              if (!play.isOver)
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
                      play.winner == null ? 'no winner' : 'winner ${Rules.pieNames[play.winner!]}',
                      style: TextStyle(
                          color: play.winner == null ? Palette.inkDim : Palette.winner, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      play.ringOrder == null ? 'no ring' : 'a ring',
                      style: TextStyle(
                          color: play.ringOrder == null ? Palette.inkDim : Palette.ring, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'moves ${play.moves}',
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
