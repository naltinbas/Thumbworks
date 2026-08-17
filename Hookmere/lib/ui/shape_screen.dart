import 'package:flutter/material.dart';

import '../best.dart';
import '../shape/level.dart';
import '../shape/play.dart';
import '../shape/rules.dart';
import 'palette.dart';
import 'result_card.dart';
import 'shapeview.dart';

/// One ask, the village laid to it.
class ShapeScreen extends StatefulWidget {
  const ShapeScreen({super.key, required this.level});

  final Level level;

  @override
  State<ShapeScreen> createState() => ShapeScreenState();
}

class ShapeScreenState extends State<ShapeScreen> {
  late Play play;

  /// What the show-me points at, or null: the row to lift from and the
  /// row to drop on.
  (int, int)? pointing;

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

  void _tap(int row) {
    if (play.isOver) return;
    final was = play;
    final holding = play.holding;
    setState(() {
      play = play.tap(row);
      pointing = null;
      refused = identical(play, was)
          ? (holding == null
              ? 'Row ${row + 1} has a row under it just as long, so its last '
                  'box is not on a corner and cannot be lifted.'
              : 'A box cannot go there: every row must stay no longer than '
                  'the one above it.')
          : null;
    });
    if (identical(play, was)) return;
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
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() {
      pointing = play.next;
      refused = null;
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

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return Play.pointed(aim, play.holding, play.rows.length);
    }
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'The hooks multiply to ${play.hookProduct} and '
          '${Rules.factorial(Rules.boxes)} over that is ${play.byHooks}, '
          'which is what counting the fillings gives.';
    }
    final head = 'The hooks multiply to ${play.hookProduct}, so the staircase '
        'has ${play.byHooks} '
        '${play.byHooks == 1 ? 'filling' : 'fillings'}.';
    return play.isDone ? 'As asked. $head' : head;
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
                  'Tap a row to lift the box off its corner and another row '
                  'to put it down: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final row = Metrics(play,
                              Size(room.maxWidth, room.maxHeight))
                          .rowNear(touch.localPosition);
                      if (row != null) _tap(row);
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: ShapeView(
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
                        'fillings ${play.byHooks}',
                        style: const TextStyle(
                            color: Palette.corner, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'hooks multiply to ${play.hookProduct}',
                        style:
                            const TextStyle(color: Palette.ink, fontSize: 13),
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
                        : refused != null
                            ? Palette.misfit
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
