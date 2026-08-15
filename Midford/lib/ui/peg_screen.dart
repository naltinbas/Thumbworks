import 'package:flutter/material.dart';

import '../best.dart';
import '../peg/cording.dart';
import '../peg/play.dart';
import '../peg/rules.dart';
import 'pegview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One cording, pegged peg by peg.
class PegScreen extends StatefulWidget {
  const PegScreen({super.key, required this.cording});

  final Cording cording;

  @override
  State<PegScreen> createState() => PegScreenState();
}

class PegScreenState extends State<PegScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, Peg)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.cording);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.cording.name));
      }
    });
  }

  void _tap(Peg? peg) {
    if (peg == null || play.isOver) return;
    setState(() {
      play = play.tap(peg);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.cording.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.cording.name);
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
      play = Play.of(widget.cording);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'lift'
          ? 'Lift the last peg: it is off the cording.'
          : 'Set the next peg in the ringed hole.';
    }
    if (play.isDone) {
      return 'Landed: the midpoint figure is ${play.figure}.';
    }
    if (!play.full) {
      return 'Pegs ${play.pegs.length} of 4; tap the next hole, or the last peg to lift it.';
    }
    return 'The midpoint figure is ${play.figure}.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.cording.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap holes to set the pegs in order, tap the last peg to '
                  'lift it: ${widget.cording.task}.',
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
                      painter: PegView(
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
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'pegs ${play.pegs.length} of 4',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.full && !play.isDone ? Palette.bad : Palette.line),
                    label: Text(
                      'figure ${play.figure}',
                      style: const TextStyle(
                          color: Palette.figure, fontSize: 13),
                    ),
                  ),
                  if (play.full)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'diagonals ${Rules.dot(Rules.firstDiagonal(play.pegs), Rules.firstDiagonal(play.pegs))} '
                        'and ${Rules.dot(Rules.secondDiagonal(play.pegs), Rules.secondDiagonal(play.pegs))} squared, '
                        'dot ${Rules.dot(Rules.firstDiagonal(play.pegs), Rules.secondDiagonal(play.pegs))}',
                        style: const TextStyle(
                            color: Palette.diagonal, fontSize: 13),
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
