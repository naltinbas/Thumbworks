import 'package:flutter/material.dart';

import '../best.dart';
import '../deck/play.dart';
import '../deck/riffle.dart';
import 'deckview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One riffle, dealt drop by drop.
class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key, required this.riffle});

  final Riffle riffle;

  @override
  State<DeckScreen> createState() => DeckScreenState();
}

class DeckScreenState extends State<DeckScreen> {
  late Play play;

  /// The pile the show-me points at, or null.
  String? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.riffle);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.riffle.name));
      }
    });
  }

  void _tap(String? pile) {
    if (pile == null || play.isOver) return;
    setState(() {
      play = play.drop(pile);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.riffle.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.riffle.name);
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
      play = Play.of(widget.riffle);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Drop from the ringed pile, the ${aim == 'A' ? 'first' : 'second'}.';
    }
    if (play.isDone) {
      return play.riffle.wantMixed
          ? 'Dealt: every block mixed.'
          : 'Dealt: a block unmixed.';
    }
    final blocks = play.blocks;
    final unmixed = blocks.where((yes) => !yes).length;
    if (play.full) {
      return unmixed == 0
          ? 'Dealt, and every block mixed.'
          : 'Dealt, and $unmixed block${unmixed == 1 ? '' : 's'} unmixed.';
    }
    return 'Dropped ${play.drops.length} of ${play.rules.length}; '
        '${blocks.length} block${blocks.length == 1 ? '' : 's'} dealt, '
        '$unmixed unmixed.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.riffle.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a pile to drop its top card onto the deck: '
                  '${widget.riffle.task}.',
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
                      painter: DeckView(
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
                      'dropped ${play.drops.length} of ${play.rules.length}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.blocks.any((yes) => !yes)
                            ? Palette.bad
                            : Palette.line),
                    label: Text(
                      'mixed ${play.blocks.where((yes) => yes).length} of ${play.blocks.length}',
                      style: TextStyle(
                          color: play.blocks.any((yes) => !yes)
                              ? Palette.bad
                              : Palette.mixed,
                          fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'piles ${play.leftA} and ${play.leftB}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
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
