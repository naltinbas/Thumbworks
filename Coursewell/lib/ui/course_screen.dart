import 'package:flutter/material.dart';

import '../best.dart';
import '../course/play.dart';
import '../course/yard.dart';
import 'courseview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One yard, bricked course by course.
class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.yard});

  final Yard yard;

  @override
  State<CourseScreen> createState() => CourseScreenState();
}

class CourseScreenState extends State<CourseScreen> {
  late Play play;

  /// The brick the show-me points at, or null.
  ((int, int), bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.yard);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.yard.name));
      }
    });
  }

  void _tap(int cell) {
    if (cell < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(cell);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.yard.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.yard.name);
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
      play = Play.of(widget.yard);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the yard says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$2
          ? 'Lay a brick across the marked cells.'
          : 'Lift the struck brick; it blocks every landing.';
    }
    if (play.isDone) {
      final seams = play.seams.length;
      return seams == 0
          ? 'Sound: every line crossed, no seam in the yard.'
          : 'Landed: exactly $seams seam${seams == 1 ? '' : 's'}, '
              'as the yard asked.';
    }
    if (play.picked != null) {
      return 'One cell picked; tap the neighbour to brick over.';
    }
    if (play.bricked) {
      final seams = play.seams.length;
      return 'Bricked whole, but $seams '
          'seam${seams == 1 ? ' stands' : 's stand'} where '
          '${play.yard.asked} ${play.yard.asked == 1 ? 'is' : 'are'} '
          'asked.';
    }
    return 'Bricks ${play.laid.length} of '
        '${play.rules.cells ~/ 2} laid.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.yard.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two cells side by side to lay a brick, or a '
                  'laid brick\'s two cells to lift it: '
                  '${widget.yard.task}.',
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
                    ).cellUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: CourseView(
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
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'bricks ${play.laid.length} of '
                      '${play.rules.cells ~/ 2}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.seam),
                    label: Text(
                      'lines uncrossed ${play.seams.length} of '
                      '${play.rules.innerLines}',
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
                  onYard: () => Navigator.of(context).pop(),
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
