import 'package:flutter/material.dart';

import '../best.dart';
import '../chain/field.dart';
import '../chain/play.dart';
import 'chainview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One field, set stone by stone.
class ChainScreen extends StatefulWidget {
  const ChainScreen({super.key, required this.field});

  final Field field;

  @override
  State<ChainScreen> createState() => ChainScreenState();
}

class ChainScreenState extends State<ChainScreen> {
  late Play play;

  /// The crossing the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.field);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.field.name));
      }
    });
  }

  void _tap((int, int)? spot) {
    if (spot == null || play.isOver) return;
    final turned = play.tapAt(spot);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.field.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.field.name);
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
      play = Play.of(widget.field);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the field says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final lifting = play.stones.contains(aim);
      return lifting
          ? 'Lift the stone ringed blue.'
          : 'Set a stone on the ringed crossing.';
    }
    if (play.isDone) {
      return 'Landed: ${play.bare} bare, as asked.';
    }
    if (play.rowBarred) {
      return 'All ${play.field.stones} share one row: the asking '
          'bars it.';
    }
    if (!play.allSet) {
      final left = play.field.stones - play.stones.length;
      return '${play.stones.length} set, $left to go; '
          '${play.bare} bare so far.';
    }
    return '${play.bare} bare chain${play.bare == 1 ? '' : 's'} '
        'show${play.bare == 1 ? 's' : ''}; '
        '${play.field.asked} asked.';
  }

  @override
  Widget build(BuildContext context) {
    final aim = pointing;
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(widget.field.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap to set or lift: ${widget.field.task}.',
                style: const TextStyle(
                    color: Palette.inkDim, fontSize: 14),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, room) => GestureDetector(
                  onTapUp: (tap) => _tap(Metrics(
                    Size(room.maxWidth, room.maxHeight),
                  ).crossUnder(tap.localPosition)),
                  child: CustomPaint(
                    painter: ChainView(
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
                  side: const BorderSide(color: Palette.bare),
                  label: Text(
                    'bare ${play.bare}',
                    style: const TextStyle(
                        color: Palette.bare, fontSize: 13),
                  ),
                ),
                Chip(
                  backgroundColor: Palette.board,
                  side: const BorderSide(color: Palette.laden),
                  label: Text(
                    'laden ${play.laden}',
                    style: const TextStyle(
                        color: Palette.laden, fontSize: 13),
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
                onHurst: () => Navigator.of(context).pop(),
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
