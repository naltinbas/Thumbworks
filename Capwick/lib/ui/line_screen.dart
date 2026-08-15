import 'package:flutter/material.dart';

import '../best.dart';
import '../line/level.dart';
import '../line/play.dart';
import 'lineview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One line, called down man by man.
class LineScreen extends StatefulWidget {
  const LineScreen({super.key, required this.level});

  final Level level;

  @override
  State<LineScreen> createState() => LineScreenState();
}

class LineScreenState extends State<LineScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

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

  void _tap(bool? call) {
    if (call == null || play.isOver) return;
    setState(() {
      play = play.tap(call);
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
    final aim = pointing;
    if (aim != null) {
      return 'The plan says ${aim.$1}: tap the ringed cap.';
    }
    if (play.isDone) {
      return 'Saved ${play.rightCount} of ${play.n}: the ask is met.';
    }
    if (play.missed) {
      return 'Saved ${play.rightCount} of ${play.n}, and the ask was ${widget.level.warden ? 'all five' : 'all but the first'}.';
    }
    final i = play.current;
    final ahead = play.blackAhead;
    final heard = [for (var j = 0; j < i; j++) if (play.calls[j]) j].length;
    final last = i == 0 ? '' : ' Man $i said ${play.calls[i - 1] ? 'black' : 'white'}, and his cap is ${play.caps[i - 1] ? 'black' : 'white'}.';
    return 'Man ${i + 1} to call: $ahead black cap${ahead == 1 ? '' : 's'} ahead, $heard called black behind.$last';
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
                  'You call for each man in turn, from the back: tap the black '
                  'cap or the white one; he sees only the caps ahead and hears '
                  'the calls behind: ${widget.level.task}.',
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
                      painter: LineView(
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
                      'called ${play.calls.length} of ${play.n}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.missed ? Palette.bad : Palette.line),
                    label: Text(
                      'right ${play.rightCount}',
                      style: TextStyle(
                          color: play.rightCount == play.calls.length || (play.calls.isNotEmpty && play.rightCount == play.calls.length - 1 && play.right(0) == false)
                              ? Palette.right
                              : Palette.bad,
                          fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      play.allCalled ? 'line done' : 'ahead ${play.blackAhead} black, ${play.blackAhead.isOdd ? 'odd' : 'even'}',
                      style: const TextStyle(
                          color: Palette.brass, fontSize: 13),
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
