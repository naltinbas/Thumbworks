import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/level.dart';
import '../yard/play.dart';
import 'yardview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One yard, paved flag by flag.
class YardScreen extends StatefulWidget {
  const YardScreen({super.key, required this.level});

  final Level level;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (Aim, int, int)? pointing;

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

  void _tap((int, int, int)? touch) {
    if (touch == null || play.isOver) return;
    _become(touch.$1 == 1 ? play.hold(touch.$2) : play.tap(touch.$2, touch.$3));
  }

  void _turn() {
    if (play.isOver) return;
    _become(play.turn());
  }

  void _become(Play next) {
    setState(() {
      play = next;
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
    if (aim != null) {
      return switch (aim.$1) {
        Aim.tray => 'Take the ${_name(aim.$2)} from the tray.',
        Aim.turn => 'Turn the half the other way up.',
        Aim.cell => 'Lay it with its corner at the ringed place.',
        Aim.lift => 'Lift the flag ringed rust: it is in the way.',
      };
    }
    if (play.isDone) return 'Paved: ${play.level.flagCount} flags, ${play.side * play.side} cells, none bare.';
    if (play.gaveUp) return play.stuck ? 'Nowhere left for a whole two: every two covers the middle.' : 'Twenty-four layings, and the yard never paved.';
    if (play.refused) return 'That does not fit there: a flag must lie inside the yard over bare cells.';
    if (play.held != null) return 'Holding the ${_name(play.held!)}: tap the yard where its top left corner goes.';
    return '${play.laid.length} of ${play.level.flagCount} laid, ${play.bareCells} cell${play.bareCells == 1 ? '' : 's'} bare; tap a tray flag to take it, a laid flag to lift it.';
  }

  String _name(int kind) {
    final (w, h, k, _) = play.kinds[kind];
    return w == h ? '$k' : 'half $k';
  }

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
                  'Take a flag from the tray and tap the yard where its top '
                  'left corner goes; Turn stands a half on end; tap a laid '
                  'flag to lift it: ${widget.level.task}.',
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
                      painter: YardView(
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
                      'laid ${play.laid.length} of ${play.level.flagCount}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'bare ${play.bareCells}',
                      style: TextStyle(
                          color: play.bareCells == 0 ? Palette.good : Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'layings ${play.moves}',
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
                      onPressed: play.isOver || play.held == null || play.kinds[play.held!].$1 == play.kinds[play.held!].$2 ? null : _turn,
                      child: const Text('Turn'),
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
