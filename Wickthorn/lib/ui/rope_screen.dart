import 'package:flutter/material.dart';

import '../best.dart';
import '../rope/green.dart';
import '../rope/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'ropeview.dart';

/// One green, roped three lanterns at a time.
class RopeScreen extends StatefulWidget {
  const RopeScreen({super.key, required this.green});

  final Green green;

  @override
  State<RopeScreen> createState() => RopeScreenState();
}

class RopeScreenState extends State<RopeScreen> {
  late Play play;

  /// The rope the show-me points at, or null.
  (int, int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.green);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.green.name));
      }
    });
  }

  void _tap(int lantern) {
    if (lantern < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(lantern);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.green.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.green.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null && play.picked.isEmpty) return;
    setState(() {
      play = play.picked.isEmpty ? play.back : play.unpicked;
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
      play = Play.of(widget.green);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the green says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      final (a, b, c) = pointing!;
      return 'Rope lanterns ${a + 1}, ${b + 1} and ${c + 1}.';
    }
    if (play.isDone) {
      return 'Closed: every pair shares exactly one rope.';
    }
    if (play.clashes.isNotEmpty) {
      final (a, b) = play.clashes.first;
      return 'Lanterns ${a + 1} and ${b + 1} share two ropes: '
          'take one back.';
    }
    if (play.picked.isNotEmpty) {
      final named =
          play.picked.map((p) => '${p + 1}').join(' and ');
      return 'Picked $named; '
          '${play.picked.length == 2 ? 'a third strings the rope' : 'pick two more'}.';
    }
    return '${play.coveredOnce} of ${play.rules.pairsNeeded} '
        'pairs share a rope; ${play.ropes.length} of '
        '${play.rules.ropesNeeded} strung.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.green.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap three lanterns to rope them: '
                  '${widget.green.task}.',
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
                    ).lanternUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: RopeView(
                        play: play,
                        pointing: pointing,
                        labels:
                            const TextStyle(fontFamily: 'Roboto'),
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
                    side: const BorderSide(color: Palette.glow),
                    label: Text(
                      'pairs ${play.coveredOnce} of '
                      '${play.rules.pairsNeeded}',
                      style: const TextStyle(
                          color: Palette.glow, fontSize: 13),
                    ),
                  ),
                  if (play.clashes.isNotEmpty)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.clash),
                      label: Text(
                        'clashes ${play.clashes.length}',
                        style: const TextStyle(
                            color: Palette.clash, fontSize: 13),
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
                  onGreen: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: play.before == null &&
                              play.picked.isEmpty
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
