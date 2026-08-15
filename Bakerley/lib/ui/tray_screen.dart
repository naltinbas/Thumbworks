import 'package:flutter/material.dart';

import '../best.dart';
import '../tray/level.dart';
import '../tray/play.dart';
import '../tray/rules.dart';
import 'trayview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One tray, filled four by four.
class TrayScreen extends StatefulWidget {
  const TrayScreen({super.key, required this.level});

  final Level level;

  @override
  State<TrayScreen> createState() => TrayScreenState();
}

class TrayScreenState extends State<TrayScreen> {
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

  void _flip() {
    if (play.isOver) return;
    _become(play.flip());
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

  /// Five buttons in the bottom row: they keep tight so a small screen
  /// holds them.
  static final _tight = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 7),
    minimumSize: const Size(36, 32),
    visualDensity: VisualDensity.compact,
  );

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return switch (aim.$1) {
        Aim.tray => 'Take the ${Rules.kindNames[aim.$2]} from the bag.',
        Aim.turn => 'Turn it a quarter.',
        Aim.flip => 'Flip it over.',
        Aim.cell => 'Lay it with its corner at the ringed cells.',
        Aim.lift => 'Lift the four ringed rust: it is in the way.',
      };
    }
    if (play.isDone) return 'Filled: ${play.level.pieces} fours, ${play.width * play.height} cells, none bare.';
    if (play.gaveUp) return play.stuck ? 'A four has nowhere left to lie: the tray never fills.' : 'Twenty-four layings, and the tray never filled.';
    if (play.refused) return 'That does not fit there: a four must lie inside the tray over bare cells.';
    if (play.held != null) return 'Holding the ${Rules.kindNames[play.held!]}: Turn and Flip it, then tap the cell for its top left corner.';
    return '${play.laid.length} of ${play.level.pieces} laid, ${play.bareCells} cell${play.bareCells == 1 ? '' : 's'} bare; tap a four in the bag to take it, a laid one to lift it.';
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
                  'Take a four from the bag, Turn or Flip it, and tap the tray '
                  'where its top left corner goes; tap a laid four to lift it: '
                  '${widget.level.task}.',
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
                      painter: TrayView(
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
                      'laid ${play.laid.length} of ${play.level.pieces}',
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
                      style: _tight,
                      onPressed: play.before == null ? null : _back,
                      child: const Text('Back'),
                    ),
                    TextButton(
                      style: _tight,
                      onPressed: play.isOver || play.held == null ? null : _turn,
                      child: const Text('Turn'),
                    ),
                    TextButton(
                      style: _tight,
                      onPressed: play.isOver || play.held == null ? null : _flip,
                      child: const Text('Flip'),
                    ),
                    TextButton(
                      style: _tight,
                      onPressed: play.isOver ? null : _show,
                      child: const Text('Show me'),
                    ),
                    TextButton(
                      style: _tight,
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
