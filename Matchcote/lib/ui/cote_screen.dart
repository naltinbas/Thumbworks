import 'package:flutter/material.dart';

import '../best.dart';
import '../round/cote.dart';
import '../round/play.dart';
import 'coteview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One cote, paired round by round.
class CoteScreen extends StatefulWidget {
  const CoteScreen({super.key, required this.cote});

  final Cote cote;

  @override
  State<CoteScreen> createState() => CoteScreenState();
}

class CoteScreenState extends State<CoteScreen> {
  late Play play;

  /// The pair the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.cote);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.cote.name));
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
      Best.landed(widget.cote.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.cote.name);
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
      play = Play.of(widget.cote);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the cote says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final (a, b) = aim;
      final unpair = play.filling.contains(aim);
      return unpair
          ? 'Unpair players ${a + 1} and ${b + 1}.'
          : 'Pair players ${a + 1} and ${b + 1}.';
    }
    if (play.isDone) {
      return 'Fixed: every pair met exactly once.';
    }
    if (play.picked != null) {
      return 'Player ${play.picked! + 1} waits; tap a partner.';
    }
    final round = play.rounds
        .where(
            (held) => held.length == play.rules.gamesARound)
        .length;
    return 'Round ${round + 1} filling: '
        '${play.filling.length} of ${play.rules.gamesARound} '
        'games paired.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.cote.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two players to pair them in the round '
                  'now filling: ${widget.cote.task}.',
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
                    ).playerUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: CoteView(
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
                    side: BorderSide(
                        color: Palette.roundCoats[
                            play.rounds.isEmpty
                                ? 0
                                : (play.rounds.length - 1) %
                                    Palette.roundCoats.length]),
                    label: Text(
                      'rounds '
                      '${play.rounds.where((held) => held.length == play.rules.gamesARound).length} '
                      'of ${play.rules.rounds}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'pairs ${play.used.length} of '
                      '${play.rules.allPairs.length}',
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
                  onCote: () => Navigator.of(context).pop(),
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
