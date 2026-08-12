import 'package:flutter/material.dart';

import '../best.dart';
import '../pane/sash.dart';
import '../pane/play.dart';
import 'paneview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One sash, glazed pane by pane.
class PaneScreen extends StatefulWidget {
  const PaneScreen({super.key, required this.sash});

  final Sash sash;

  @override
  State<PaneScreen> createState() => PaneScreenState();
}

class PaneScreenState extends State<PaneScreen> {
  late Play play;

  /// The crossing the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.sash);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.sash.name));
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
      Best.landed(widget.sash.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.sash.name);
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
      play = Play.of(widget.sash);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sash says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final lifting = play.panes.contains(aim);
      return lifting
          ? 'Lift the pane ringed blue.'
          : 'Set a pane in the ringed light.';
    }
    if (play.isDone) {
      return 'Glazed: ${play.sash.count} panes, not a window.';
    }
    if (play.windows > 0) {
      return '${play.windows} window${play.windows == 1 ? '' : 's'} '
          'framed: lift a rust corner.';
    }
    final left = play.sash.count - play.panes.length;
    return '${play.panes.length} set, $left to go; nothing '
        'framed yet.';
  }

  @override
  Widget build(BuildContext context) {
    final aim = pointing;
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(widget.sash.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap to set or lift: ${widget.sash.task}.',
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
                  ).lightUnder(tap.localPosition)),
                  child: CustomPaint(
                    painter: PaneView(
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
                  side: const BorderSide(color: Palette.glass),
                  label: Text(
                    'panes ${play.panes.length} of '
                    '${play.sash.count}',
                    style: const TextStyle(
                        color: Palette.glass, fontSize: 13),
                  ),
                ),
                Chip(
                  backgroundColor: Palette.board,
                  side: const BorderSide(color: Palette.window),
                  label: Text(
                    'windows ${play.windows}',
                    style: const TextStyle(
                        color: Palette.window, fontSize: 13),
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
                onMoor: () => Navigator.of(context).pop(),
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
