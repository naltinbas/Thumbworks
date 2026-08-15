import 'package:flutter/material.dart';

import '../best.dart';
import '../stall/level.dart';
import '../stall/play.dart';
import '../stall/rules.dart';
import 'stallview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One stall, set dial by dial.
class StallScreen extends StatefulWidget {
  const StallScreen({super.key, required this.level});

  final Level level;

  @override
  State<StallScreen> createState() => StallScreenState();
}

class StallScreenState extends State<StallScreen> {
  late Play play;

  /// What the show-me points at, or null.
  String? pointing;

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

  void _set(String what) {
    if (play.isOver) return;
    setState(() {
      play = switch (what) {
        'doors+' => play.moreDoors(1),
        'doors-' => play.moreDoors(-1),
        'opened+' => play.moreOpened(1),
        'opened-' => play.moreOpened(-1),
        _ => play.togglePolicy(),
      };
      pointing = null;
    });
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
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return switch (aim) {
        'doors+' => 'Add a door.',
        'doors-' => 'Take a door away.',
        'opened+' => 'Have the host open one more.',
        'opened-' => 'Have the host open one fewer.',
        _ => play.switching ? 'Stay instead.' : 'Switch instead.',
      };
    }
    final stay = play.stayChance, sw = play.switchChance;
    final words = '${play.doors} doors, ${play.opened} opened: staying wins ${stay.$1} in ${stay.$2}, switching ${sw.$1} in ${sw.$2}, ${Rules.inHundred(sw)} in a hundred.';
    if (play.gaveUp) return 'Twenty-four settings, and switching ahead in every one.';
    return play.isDone ? 'As asked. $words' : words;
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
                  'Set the doors and how many goats the host opens, and stay '
                  'or switch; the table below is every case, the cart down the '
                  'side and the pick across: ${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: StallView(
                    play: play,
                    pointing: pointing,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!play.isOver)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final what in const ['doors-', 'doors+', 'opened-', 'opened+'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: OutlinedButton(
                            key: Key(what),
                            onPressed: () => _set(what),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(40, 34),
                              side: BorderSide(color: pointing == what ? Palette.shown : Palette.line, width: pointing == what ? 2 : 1),
                            ),
                            child: Text(switch (what) {
                              'doors-' => 'doors -',
                              'doors+' => 'doors +',
                              'opened-' => 'opens -',
                              _ => 'opens +',
                            }),
                          ),
                        ),
                    ],
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
                      'doors ${play.doors}, opens ${play.opened}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      '${play.switching ? 'switch' : 'stay'} ${play.chance.$1} in ${play.chance.$2}',
                      style: TextStyle(
                          color: play.switching ? Palette.cellPart : Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'settings ${play.moves}',
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
                      key: const Key('policy'),
                      onPressed: play.isOver ? null : () => _set('policy'),
                      style: TextButton.styleFrom(foregroundColor: pointing == 'policy' ? Palette.shown : Palette.cellPart),
                      child: Text(play.switching ? 'Switch' : 'Stay'),
                    ),
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
