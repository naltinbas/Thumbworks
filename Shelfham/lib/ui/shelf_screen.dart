import 'package:flutter/material.dart';

import '../best.dart';
import '../shelf/shelf.dart';
import '../shelf/play.dart';
import 'shelfview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One shelf, swapped book by book.
class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key, required this.shelf});

  final Shelf shelf;

  @override
  State<ShelfScreen> createState() => ShelfScreenState();
}

class ShelfScreenState extends State<ShelfScreen> {
  late Play play;

  /// The place and book the show-me points at, or null.
  (int, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.shelf);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.shelf.name));
      }
    });
  }

  void _tap(int post) {
    if (post < 0 || play.isOver) return;
    setState(() {
      play = play.tapAt(post);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.shelf.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.shelf.name);
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
      play = Play.of(widget.shelf);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the shelf says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Put book ${aim.$2 + 1} at place ${aim.$1 + 1}.';
    }
    if (play.isDone) {
      return 'Shelved: ${play.stepsDown.length} '
          'step${play.stepsDown.length == 1 ? '' : 's'} down, '
          'as asked.';
    }
    if (play.picked != null) {
      return 'Book at place ${play.picked! + 1} in hand; tap '
          'another to swap.';
    }
    return '${play.stepsDown.length} '
        'step${play.stepsDown.length == 1 ? '' : 's'} down; '
        '${play.shelf.asked} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.shelf.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap two books to swap their places: '
                  '${widget.shelf.task}.',
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
                    ).placeUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: ShelfView(
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
                    side: const BorderSide(color: Palette.step),
                    label: Text(
                      'steps down ${play.stepsDown.length}',
                      style: const TextStyle(
                          color: Palette.step, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'asked ${play.shelf.asked}',
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
                  onHam: () => Navigator.of(context).pop(),
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
