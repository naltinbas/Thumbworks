import 'package:flutter/material.dart';

import '../best.dart';
import '../wire/combe.dart';
import '../wire/play.dart';
import 'combeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One combe, wired cottage to cottage.
class CombeScreen extends StatefulWidget {
  const CombeScreen({super.key, required this.combe});

  final Combe combe;

  @override
  State<CombeScreen> createState() => CombeScreenState();
}

class CombeScreenState extends State<CombeScreen> {
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
    play = Play.of(widget.combe);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.combe.name));
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
      Best.landed(widget.combe.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.combe.name);
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
      play = Play.of(widget.combe);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the combe says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final ((a, b), wire) = aim;
      return wire
          ? 'Wire cottages ${a + 1} and ${b + 1}.'
          : 'Unwire cottages ${a + 1} and ${b + 1}.';
    }
    if (play.isDone) {
      return 'Wired: one run, '
          '${play.lanesEnds.length} lane\'s '
          'end${play.lanesEnds.length == 1 ? '' : 's'} lit.';
    }
    if (play.looped) {
      return 'The wire loops: unwire something.';
    }
    if (play.picked != null) {
      return 'Picked cottage ${play.picked! + 1}; tap another '
          'to wire them.';
    }
    if (play.lines.length == play.combe.cottages - 1 &&
        play.pieces > 1) {
      return '${play.pieces} pieces stand: this is no single run.';
    }
    final left = play.combe.cottages - 1 - play.lines.length;
    return '${play.lines.length} wired, $left to go; '
        '${play.lanesEnds.length} window'
        '${play.lanesEnds.length == 1 ? '' : 's'} lit.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.combe.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two cottages to wire them, or a wired '
                  'pair to unwire: ${widget.combe.task}.',
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
                    ).cottageUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: CombeView(
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
                    side: const BorderSide(color: Palette.wire),
                    label: Text(
                      'lines ${play.lines.length} of '
                      '${play.combe.cottages - 1}',
                      style: const TextStyle(
                          color: Palette.wire, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side:
                        const BorderSide(color: Palette.lanesEnd),
                    label: Text(
                      'ends ${play.lanesEnds.length}',
                      style: const TextStyle(
                          color: Palette.lanesEnd, fontSize: 13),
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
                  onCombe: () => Navigator.of(context).pop(),
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
