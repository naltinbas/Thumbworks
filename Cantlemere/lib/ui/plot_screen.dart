import 'package:flutter/material.dart';

import '../best.dart';
import '../plot/level.dart';
import '../plot/play.dart';
import '../plot/rules.dart';
import 'palette.dart';
import 'plotview.dart';
import 'result_card.dart';

/// One ask, the field laid to it.
class PlotScreen extends StatefulWidget {
  const PlotScreen({super.key, required this.level});

  final Level level;

  @override
  State<PlotScreen> createState() => PlotScreenState();
}

class PlotScreenState extends State<PlotScreen> {
  late Play play;

  /// The peg the show-me points at, or null.
  int? pointing;

  /// What the last tap did, when it did nothing.
  String? refused;

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

  void _tap(int peg) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.tap(peg);
      pointing = null;
      refused = identical(play, was)
          ? 'Those three pegs make no plot: they fall in a line, or the plot '
              'would lie over one already down.'
          : null;
    });
    if (identical(play, was)) return;
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.taps).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
          });
        }
      });
    }
  }

  void _lift(int plot) {
    if (play.isOver) return;
    setState(() {
      play = play.lift(plot);
      pointing = null;
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _miss() {
    if (play.isOver) return;
    setState(() {
      pointing = null;
      refused = 'Tap a peg to take a corner, or tap a plot to lift it off '
          'again.';
    });
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      pointing = null;
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() {
      pointing = play.next;
      refused = pointing == null
          ? 'Nothing on the field can be carried on with. Lift a plot off.'
          : null;
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
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the field says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'Every cut into three leaves a plot of 9 half acres, half the '
          'field, and one plot wearing all three colours.';
    }
    if (play.isDone) return 'As asked.';
    if (play.holding.isNotEmpty) {
      final more = 3 - play.holding.length;
      return '${play.holding.length} of three pegs taken. $more more and the '
          'plot goes down.';
    }
    if (play.laid.isEmpty) return 'Tap three pegs to lay the first plot.';
    return '${play.laid.length} '
        '${play.laid.length == 1 ? 'plot' : 'plots'} laid, ${play.left} half '
        '${play.left == 1 ? 'acre' : 'acres'} left.';
  }

  /// What the board draws. Once the last ask has been admitted it shows
  /// a cut into three plots, since that is what the card is about.
  Play get shown => play.gaveUp ? play.asThree : play;

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
                  'Tap three pegs to lay a plot: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final m = Metrics(
                          play, Size(room.maxWidth, room.maxHeight));
                      final peg = m.pegNear(touch.localPosition);
                      if (peg != null) {
                        _tap(peg);
                        return;
                      }
                      final plot = m.plotUnder(touch.localPosition);
                      if (plot != null) {
                        _lift(plot);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: PlotView(
                        play: shown,
                        pointing: pointing,
                        showWhyNot: play.gaveUp,
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
                          color: play.laid.length == widget.level.pieces
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        'plots ${play.laid.length} of '
                        '${widget.level.pieces}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.left == 0 ? Palette.good : Palette.line),
                      label: Text(
                        'left ${play.left} of ${Rules.field}',
                        style: TextStyle(
                          color: play.left == 0
                              ? Palette.good
                              : Palette.plotEdge,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'taps ${play.taps}',
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
                        : refused != null
                            ? Palette.bad
                            : play.isDone
                                ? Palette.good
                                : Palette.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              if (play.isOver)
                // The card runs long on a small phone, so it is given
                // room to scroll rather than pushing the buttons off.
                Flexible(
                  child: SingleChildScrollView(
                    child: ResultCard(
                      play: play,
                      fewest: fewest,
                      isRecord: isRecord,
                      onAgain: _again,
                      onField: () => Navigator.of(context).pop(),
                    ),
                  ),
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
