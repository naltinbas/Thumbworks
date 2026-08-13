import 'package:flutter/material.dart';

import '../best.dart';
import '../row/asking.dart';
import '../row/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'rowview.dart';

/// One asking, wound row by row.
class RowScreen extends StatefulWidget {
  const RowScreen({super.key, required this.asking});

  final Asking asking;

  @override
  State<RowScreen> createState() => RowScreenState();
}

class RowScreenState extends State<RowScreen> {
  late Play play;

  /// The wind the show-me points at, or null.
  bool? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.asking);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.asking.name));
      }
    });
  }

  void _wind(int by) {
    if (play.isOver) return;
    setState(() {
      play = play.windBy(by);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.asking.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.asking.name);
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
      play = Play.of(widget.asking);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the wall says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Wind ${aim ? 'down the wall' : 'back up'} toward '
          'a landing row.';
    }
    if (play.isDone) {
      return 'Wound home: row ${play.at} holds exactly '
          '${play.odds} odd${play.odds == 1 ? '' : 's'}.';
    }
    return 'Row ${play.at} holds ${play.odds} '
        'odd${play.odds == 1 ? '' : 's'} where '
        '${widget.asking.odds} ${widget.asking.odds == 1 ? 'is' : 'are'} '
        'asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.asking.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Wind the wall a row at a time; the odds of '
                  'the wound row light gold: ${widget.asking.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: RowView(
                    play: play,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone
                            ? Palette.woundOdd
                            : Palette.line),
                    label: Text(
                      'odds ${play.odds}, asked '
                      '${widget.asking.odds}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'row ${play.at}',
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
                  onWall: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed:
                          play.isOver ? null : () => _wind(-1),
                      child: const Text('wind up'),
                    ),
                    OutlinedButton(
                      onPressed:
                          play.isOver ? null : () => _wind(1),
                      child: const Text('wind down'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
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
