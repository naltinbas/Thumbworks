import 'package:flutter/material.dart';

import '../best.dart';
import '../clink/feast.dart';
import '../clink/play.dart';
import 'clinkview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One feast, clinked pair by pair.
class ClinkScreen extends StatefulWidget {
  const ClinkScreen({super.key, required this.feast});

  final Feast feast;

  @override
  State<ClinkScreen> createState() => ClinkScreenState();
}

class ClinkScreenState extends State<ClinkScreen> {
  late Play play;

  /// The pair the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.feast);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.feast.name));
      }
    });
  }

  void _tap(int? pair) {
    if (pair == null || play.isOver) return;
    setState(() {
      play = play.flipAt(pair);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.feast.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.feast.name);
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
      play = Play.of(widget.feast);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the field says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return play.clinked[aim]
          ? 'Take back the ringed clink.'
          : 'Clink the ringed pair.';
    }
    if (play.isDone) {
      return 'Feasted: exactly ${play.distinct} different '
          'count${play.distinct == 1 ? '' : 's'}, as asked.';
    }
    return '${play.distinct} different '
        'count${play.distinct == 1 ? ' stands' : 's stand'} where '
        '${widget.feast.asked} ${widget.feast.asked == 1 ? 'is' : 'are'} '
        'asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.feast.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap the line between two guests to clink or '
                  'take back: ${widget.feast.task}.',
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
                    ).pairUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: ClinkView(
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
                            ? Palette.good
                            : Palette.line),
                    label: Text(
                      'counts ${play.distinct}, asked '
                      '${widget.feast.asked}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'clinks ${play.raised}',
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
                  onField: () => Navigator.of(context).pop(),
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
