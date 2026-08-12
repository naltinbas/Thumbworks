import 'package:flutter/material.dart';

import '../best.dart';
import '../watch/mere.dart';
import '../watch/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'watchview.dart';

/// One mere, slid watch by watch.
class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key, required this.mere});

  final Mere mere;

  @override
  State<WatchScreen> createState() => WatchScreenState();
}

class WatchScreenState extends State<WatchScreen> {
  late Play play;

  /// The slide the show-me points at, or null.
  (int, bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.mere);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.mere.name));
      }
    });
  }

  void _tap((int, bool)? hit) {
    if (hit == null || play.isOver) return;
    setState(() {
      play = play.slideAt(hit.$1, hit.$2 ? -1 : 1);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.mere.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.mere.name);
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
      play = Play.of(widget.mere);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the mere says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Slide the ringed watch '
          '${aim.$2 ? 'later' : 'earlier'}.';
    }
    if (play.isDone) {
      return 'Dialled home: the night stands as asked.';
    }
    final held = play.commonWidth;
    return '${play.pairs} of ${play.rules.allPairs} pairs '
        'overlap; ${held == 0 ? 'no hour is' : held == 1 ? 'one hour is' : '$held hours are'} '
        'shared.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.mere.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a watch\'s left half to slide it earlier, '
                  'its right half later: ${widget.mere.task}.',
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
                    ).watchUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: WatchView(
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
                        color: play.isDone
                            ? Palette.sharedRim
                            : Palette.line),
                    label: Text(
                      'pairs ${play.pairs} of ${play.rules.allPairs}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'shared hours ${play.commonWidth}',
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
                  onMere: () => Navigator.of(context).pop(),
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
