import 'package:flutter/material.dart';

import '../best.dart';
import '../gap/play.dart';
import '../gap/stile.dart';
import 'gapview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One stile, dialed.
class GapScreen extends StatefulWidget {
  const GapScreen({super.key, required this.stile});

  final Stile stile;

  @override
  State<GapScreen> createState() => GapScreenState();
}

class GapScreenState extends State<GapScreen> {
  late Play play;

  /// The dial the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.stile);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.stile.name));
      }
    });
  }

  void _turn(Play turned) {
    if (play.isOver) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.stile.name, play.dials).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.stile.name);
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
      play = Play.of(widget.stile);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the hoop says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Dial to ${aim.$1} over ${aim.$2}.';
    }
    if (!play.allApart) {
      return 'Only ${play.spots.length} of the '
          '${play.stile.pegs} pegs stand apart: the stride shares '
          'a factor with the round, so pegs land on pegs.';
    }
    final showing = play.sizeCount;
    if (play.isDone) return 'Landed: $showing, as asked.';
    return '$showing gap length${showing == 1 ? '' : 's'} '
        'show${showing == 1 ? 's' : ''}; '
        '${play.stile.asked} asked.';
  }

  Widget _dial(String name, int value, void Function(int) by,
      {required bool lit}) {
    final coat = lit ? Palette.shown : Palette.line;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            name,
            style: const TextStyle(
                color: Palette.inkDim, fontSize: 14),
          ),
        ),
        OutlinedButton(
          onPressed: play.isOver ? null : () => by(-1),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(52, 44),
            side: BorderSide(color: coat),
          ),
          child: const Text('−'),
        ),
        SizedBox(
          width: 46,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: play.isOver ? null : () => by(1),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(52, 44),
            side: BorderSide(color: coat),
          ),
          child: const Text('+'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aim = pointing;
    final gaps = play.gapsNow;
    final sizes = gaps.toSet().toList()..sort();
    const coats = [Palette.gapOne, Palette.gapTwo, Palette.gapThree];
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(widget.stile.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Dial a stride: ${widget.stile.task}.',
                style: const TextStyle(
                    color: Palette.inkDim, fontSize: 14),
              ),
            ),
            Expanded(
              child: CustomPaint(
                painter: GapView(
                  play: play,
                  labels: const TextStyle(fontFamily: 'Roboto'),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (var at = 0; at < sizes.length; at++)
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(color: coats[at]),
                    label: Text(
                      '${sizes[at]} '
                      'hole${sizes[at] == 1 ? '' : 's'} '
                      '×${gaps.where((gap) => gap == sizes[at]).length}',
                      style: TextStyle(color: coats[at], fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            _dial('stride', play.stride,
                (by) => _turn(play.strideBy(by)),
                lit: aim != null && aim.$1 != play.stride),
            _dial('round', play.round, (by) => _turn(play.roundBy(by)),
                lit: aim != null && aim.$2 != play.round),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                verdict(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: aim != null
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
                onFence: () => Navigator.of(context).pop(),
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
}
