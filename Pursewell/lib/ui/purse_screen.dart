import 'package:flutter/material.dart';

import '../best.dart';
import '../purse/play.dart';
import '../purse/purse.dart';
import 'palette.dart';
import 'purseview.dart';
import 'result_card.dart';

/// One purse, paid coin by coin.
class PurseScreen extends StatefulWidget {
  const PurseScreen({super.key, required this.purse});

  final Purse purse;

  @override
  State<PurseScreen> createState() => PurseScreenState();
}

class PurseScreenState extends State<PurseScreen> {
  late Play play;

  /// The coin the show-me points at, or null.
  (int, bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.purse);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.purse.name));
      }
    });
  }

  void _tap(int coin) {
    if (coin < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(coin);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.purse.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.purse.name);
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
      play = Play.of(widget.purse);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the purse says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$2
          ? 'Put the ${aim.$1} in the tray.'
          : 'Take the ${aim.$1} back out.';
    }
    if (play.isDone) {
      return 'Paid: ${play.purse.price} on the coin.';
    }
    if (play.neighbours.isNotEmpty) {
      final (a, b) = play.neighbours.first;
      return 'The $a and the $b are neighbours in the coinage: '
          'one must come out.';
    }
    final short = play.purse.price - play.total;
    if (short == 0 && play.purse.secondWay) {
      return 'Paid the shown way; the asking wants another.';
    }
    return short > 0
        ? '${play.total} in the tray; $short short.'
        : '${play.total} in the tray; ${-short} over.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.purse.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a coin to move it: ${widget.purse.task}.',
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
                    ).coinUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: PurseView(
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
                    side: const BorderSide(color: Palette.coin),
                    label: Text(
                      'tray ${play.total} of ${play.purse.price}',
                      style: const TextStyle(
                          color: Palette.coin, fontSize: 13),
                    ),
                  ),
                  if (play.neighbours.isNotEmpty)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(
                          color: Palette.neighbour),
                      label: Text(
                        'neighbours ${play.neighbours.length}',
                        style: const TextStyle(
                            color: Palette.neighbour, fontSize: 13),
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
                  onWell: () => Navigator.of(context).pop(),
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
