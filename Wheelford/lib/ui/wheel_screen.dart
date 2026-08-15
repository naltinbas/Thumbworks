import 'package:flutter/material.dart';

import '../best.dart';
import '../wheel/cording.dart';
import '../wheel/play.dart';
import '../wheel/rules.dart';
import 'wheelview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One cording, pegged peg by peg.
class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key, required this.cording});

  final Cording cording;

  @override
  State<WheelScreen> createState() => WheelScreenState();
}

class WheelScreenState extends State<WheelScreen> {
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
          ? 'Lift the ringed peg: it is off the cording.'
          : 'Cord the ringed peg.';
    }
    if (play.isDone) {
      return 'Landed: ${play.cording.task.replaceFirst('cord ', '').replaceFirst('set ', '')}.';
    }
    if (!play.full) {
      return 'Pegs ${play.pegs.length} of ${play.cording.pegs}; tap a rim peg.';
    }
    if (play.pegs.length == 3) {
      final corners = play.squareCorners;
      if (corners.isEmpty) {
        return Rules.sharp(play.pegs)
            ? 'Sharp at every corner, no diameter among the cords.'
            : 'A blunt corner, no diameter among the cords.';
      }
      final i = corners.first;
      return 'Square at peg ${i + 1}, across a diameter.';
    }
    return Rules.makesSquare(play.pegs) ? 'A square.' : 'Four pegs, not a square.';
  }

  static int _diameters(List<Peg> pegs) {
    var count = 0;
    for (var i = 0; i < pegs.length; i++) {
      for (var j = i + 1; j < pegs.length; j++) {
        if (Rules.isDiameter(pegs[i], pegs[j])) count++;
      }
    }
    return count;
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
                  'Tap rim pegs to cord them, tap a corded peg to lift it: '
                  '${widget.cording.task}.',
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
                      painter: WheelView(
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
                      'pegs ${play.pegs.length} of ${widget.cording.pegs}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  if (play.pegs.length == 3)
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.squareCorners.isNotEmpty ? Palette.squareMark : Palette.line),
                      label: Text(
                        play.squareCorners.isNotEmpty
                            ? 'square corner at peg ${play.squareCorners.first + 1}'
                            : Rules.sharp(play.pegs)
                                ? 'sharp all round'
                                : 'a blunt corner',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 13),
                      ),
                    ),
                  if (play.pegs.length >= 2)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'diameters ${_diameters(play.pegs)}',
                        style: const TextStyle(
                            color: Palette.diameter, fontSize: 13),
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
