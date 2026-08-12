import 'package:flutter/material.dart';

import '../best.dart';
import '../debt/play.dart';
import '../debt/village.dart';
import 'fenview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One village, settled or not.
class FenScreen extends StatefulWidget {
  const FenScreen({super.key, required this.village});

  final Village village;

  @override
  State<FenScreen> createState() => FenScreenState();
}

class FenScreenState extends State<FenScreen> {
  late Play play;

  /// Whether a tap lends or borrows.
  bool lending = true;

  /// The house the show-me points at, or -1, with its move.
  int pointing = -1;
  bool pointedLend = true;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.village);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.village.name));
      }
    });
  }

  void _tap(int house) {
    if (house < 0 || play.isOver) return;
    setState(() {
      play = lending ? play.lendAt(house) : play.borrowAt(house);
      pointing = -1;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.village.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.village.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      pointing = -1;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    final aim = play.next;
    setState(() {
      if (aim == null) {
        pointing = -1;
      } else {
        pointing = aim.$1;
        pointedLend = aim.$2;
        lending = aim.$2;
      }
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
      play = Play.of(widget.village);
      pointing = -1;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the ledger says of the village as it stands.
  String verdict() {
    if (pointing >= 0) {
      final name = play.village.houseNames[pointing];
      return pointedLend ? 'Lend from $name.' : 'Borrow at $name.';
    }
    if (play.isDone) {
      return 'Every house clear.';
    }
    final owing = play.pounds.where((p) => p < 0).length;
    final debt =
        play.pounds.where((p) => p < 0).fold(0, (a, p) => a - p);
    return '$owing house${owing == 1 ? '' : 's'} owing '
        '$debt pound${debt == 1 ? '' : 's'}; '
        '${play.moves} move${play.moves == 1 ? '' : 's'} taken.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.village.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a house: ${widget.village.task}.',
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
                    ).houseUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: FenView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final (label, lends) in const [
                    ('Lend', true),
                    ('Borrow', false),
                  ])
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton(
                        onPressed: play.isOver
                            ? null
                            : () => setState(() => lending = lends),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(96, 42),
                          side: BorderSide(
                            color: lending == lends
                                ? Palette.coin
                                : Palette.line,
                            width: lending == lends ? 2.0 : 1.0,
                          ),
                        ),
                        child: Text(label),
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
                    color: pointing >= 0
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
                  onFen: () => Navigator.of(context).pop(),
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
