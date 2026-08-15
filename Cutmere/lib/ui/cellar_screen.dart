import 'package:flutter/material.dart';

import '../best.dart';
import '../cellar/level.dart';
import '../cellar/play.dart';
import 'cellarview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One cellar, searched question by question.
class CellarScreen extends StatefulWidget {
  const CellarScreen({super.key, required this.level});

  final Level level;

  @override
  State<CellarScreen> createState() => CellarScreenState();
}

class CellarScreenState extends State<CellarScreen> {
  late Play play;

  /// What the show-me points at, or null.
  int? pointing;

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

  void _tap(int? cask) {
    if (cask == null || play.isOver) return;
    setState(() {
      play = play.cutAt(cask);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.asked).then((record) {
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
    setState(() {
      final mid = play.next;
      pointing = mid == null ? null : play.from + mid - 1;
    });
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
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    if (pointing != null) return 'Ask after the ringed cask, the middle of what is left.';
    if (play.found) {
      return play.isDone
          ? 'Found: cask ${play.from + 1} holds the coin, in ${play.asked} question${play.asked == 1 ? '' : 's'}.'
          : 'Found, cask ${play.from + 1}, but in ${play.asked} questions, one too many.';
    }
    if (play.spent) return 'The questions are spent and ${play.size} casks still might.';
    final said = play.answers.isEmpty ? '' : 'He says the ${play.answers.last ? 'right' : 'left'} part. ';
    return '$said${play.size} casks might, ${play.stillNeeded} question${play.stillNeeded == 1 ? '' : 's'} '
        'needed; tap a cask to ask whether the coin is among the casks up to it.';
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
                  'Tap a cask to ask whether the coin is among the casks up to '
                  'it; the cellarman answers to keep you guessing, and the '
                  'casks ruled out go dark: ${widget.level.task}.',
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
                      painter: CellarView(
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
                        color: play.isDone ? Palette.good : play.spent ? Palette.bad : Palette.line),
                    label: Text(
                      'questions ${play.asked} of ${widget.level.questions}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.found ? Palette.good : Palette.line),
                    label: Text(
                      'casks left ${play.size}',
                      style: TextStyle(
                          color: play.found ? Palette.good : Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.stillNeeded > widget.level.questions - play.asked && !play.found ? Palette.bad : Palette.line),
                    label: Text(
                      'needs ${play.stillNeeded}',
                      style: TextStyle(
                          color: play.stillNeeded > widget.level.questions - play.asked && !play.found ? Palette.bad : Palette.inkDim, fontSize: 13),
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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
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
