import 'package:flutter/material.dart';

import '../best.dart';
import '../table/level.dart';
import '../table/play.dart';
import 'tableview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One table, set side by side.
class TableScreen extends StatefulWidget {
  const TableScreen({super.key, required this.level});

  final Level level;

  @override
  State<TableScreen> createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {
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
        'along+' => play.moreAlong(1),
        'along-' => play.moreAlong(-1),
        'up+' => play.moreUp(1),
        _ => play.moreUp(-1),
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
        'along+' => 'Lengthen the table along.',
        'along-' => 'Shorten the table along.',
        'up+' => 'Lengthen the table up.',
        _ => 'Shorten the table up.',
      };
    }
    final words = '${play.along} by ${play.up}: ${play.bounces} bounce${play.bounces == 1 ? '' : 's'} in ${play.steps} steps, and the ball drops in ${play.pocketName}.';
    if (play.gaveUp) return 'Twenty-four tables, and the ball never home.';
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
                  'Set the sides, and the ball is shot from the home corner at '
                  'forty-five degrees, its path in chalk and its bounces marked: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: TableView(
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
                      for (final what in const ['along-', 'along+', 'up-', 'up+'])
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
                              'along-' => 'along -',
                              'along+' => 'along +',
                              'up-' => 'up -',
                              _ => 'up +',
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
                      'table ${play.along} by ${play.up}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'bounces ${play.bounces}',
                      style: const TextStyle(
                          color: Palette.bounce, fontSize: 13),
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
