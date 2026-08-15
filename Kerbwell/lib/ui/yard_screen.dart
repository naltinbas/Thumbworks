import 'package:flutter/material.dart';

import '../best.dart';
import '../yard/play.dart';
import '../yard/rules.dart';
import '../yard/yard.dart';
import 'yardview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One yard, laid slab by slab.
class YardScreen extends StatefulWidget {
  const YardScreen({super.key, required this.yard});

  final Yard yard;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, Cell)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.yard);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.yard.name));
      }
    });
  }

  void _tap(Cell? cell) {
    if (cell == null || play.isOver) return;
    setState(() {
      play = play.tap(cell);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.yard.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.yard.name);
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
      play = Play.of(widget.yard);
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
          ? 'Lift the ringed slab: it is off the placing.'
          : 'Lay a slab in the ringed cell.';
    }
    if (play.isDone) {
      return 'Laid: ${play.yard.slabs} slabs in a kerb of ${play.kerb}.';
    }
    if (play.slabs.length > 1 && !play.joined) {
      return 'The slabs are not joined edge to edge.';
    }
    if (play.slabs.length == play.yard.slabs) {
      return 'Kerb ${play.kerb}, asked ${play.yard.asked}.';
    }
    return 'Slabs ${play.slabs.length} of ${play.yard.slabs}, kerb ${play.kerb}.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.yard.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a cell to lay a slab, tap a slab to lift it: '
                  '${widget.yard.task}.',
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
                      'slabs ${play.slabs.length} of ${widget.yard.slabs}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.slabs.length == widget.yard.slabs &&
                                play.kerb != widget.yard.asked
                            ? Palette.bad
                            : play.kerb == widget.yard.asked &&
                                    play.slabs.length == widget.yard.slabs
                                ? Palette.good
                                : Palette.line),
                    label: Text(
                      'kerb ${play.kerb}, asked ${widget.yard.asked}',
                      style: const TextStyle(
                          color: Palette.kerb, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      play.slabs.isEmpty
                          ? 'box none'
                          : 'box ${play.box.$1} by ${play.box.$2}, kerb ${play.boxKerb}',
                      style: const TextStyle(
                          color: Palette.box, fontSize: 13),
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
