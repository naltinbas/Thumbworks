import 'package:flutter/material.dart';

import '../best.dart';
import '../count/play.dart';
import '../count/tray.dart';
import 'trayview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One tray, filled count by count.
class TrayScreen extends StatefulWidget {
  const TrayScreen({super.key, required this.tray});

  final Tray tray;

  @override
  State<TrayScreen> createState() => TrayScreenState();
}

class TrayScreenState extends State<TrayScreen> {
  late Play play;

  /// The count the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.tray);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.tray.name));
      }
    });
  }

  void _tap(int? slot) {
    if (slot == null || play.isOver) return;
    setState(() {
      // The last egg tapped again comes out; any other slot fills
      // to there.
      play = play.fill(slot == play.eggs ? slot - 1 : slot);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.tray.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.tray.name);
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
      play = Play.of(widget.tray);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Fill the tray to the ringed slot: $aim eggs.';
    }
    if (play.isDone) {
      return 'Met: ${play.eggs} eggs leave what was asked.';
    }
    final metCount = play.met.where((yes) => yes).length;
    return '${play.eggs} egg${play.eggs == 1 ? '' : 's'}; '
        '$metCount of ${play.tray.rows.length} askings met.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.tray.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a slot to fill the tray up to it, tap the last '
                  'egg to take it out: ${widget.tray.task}.',
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
                      painter: TrayView(
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
                      'eggs ${play.eggs}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  for (var i = 0; i < widget.tray.rows.length; i++)
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.met[i] ? Palette.met : Palette.line),
                      label: Text(
                        'by ${widget.tray.rows[i]}s ${play.leftovers[i]} '
                        'of ${widget.tray.asked[i]}',
                        style: TextStyle(
                            color: play.met[i] ? Palette.met : Palette.inkDim,
                            fontSize: 13),
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
