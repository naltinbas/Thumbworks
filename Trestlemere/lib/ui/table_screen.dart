import 'package:flutter/material.dart';

import '../best.dart';
import '../table/level.dart';
import '../table/play.dart';
import '../table/rules.dart';
import 'palette.dart';
import 'result_card.dart';
import 'tableview.dart';

/// One ask, the hall laid to it.
class TableScreen extends StatefulWidget {
  const TableScreen({super.key, required this.level});

  final Level level;

  @override
  State<TableScreen> createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {
  late Play play;

  /// The guest the hand has hold of, or null.
  int? holding;

  /// The guest and trestle the show-me points at, or null.
  (int, int)? pointing;

  /// What the last tap did, when it did nothing.
  String? refused;

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

  void _take(int guest) {
    if (play.isOver) return;
    setState(() {
      holding = holding == guest ? null : guest;
      pointing = null;
      refused = null;
    });
  }

  void _put(int trestle) {
    if (play.isOver) return;
    final hand = holding;
    if (hand == null) {
      setState(() {
        pointing = null;
        refused = 'Tap a guest first, then the trestle to move them to.';
      });
      return;
    }
    final was = play;
    setState(() {
      play = play.sit(hand, trestle);
      holding = null;
      pointing = null;
      refused = identical(play, was)
          ? '${Rules.name(hand)} is already at that trestle.'
          : null;
    });
    if (identical(play, was)) return;
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

  void _miss() {
    if (play.isOver) return;
    setState(() {
      pointing = null;
      refused = 'Tap a guest, then tap a trestle.';
    });
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      holding = null;
      pointing = null;
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() {
      pointing = play.next;
      refused = null;
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
      holding = null;
      pointing = null;
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the hall says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'Four different tables want '
          '${Rules.fewestFor(widget.level.tables)} guests and there are '
          '${Rules.guests}.';
    }
    if (play.isDone) return 'As asked.';
    if (holding != null) {
      return '${Rules.name(holding!)} is up. Tap the trestle to sit them at.';
    }
    return '${play.laid} ${play.laid == 1 ? 'table' : 'tables'} laid, of '
        '${play.sizes.join(', ')}.';
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
                  'Tap a guest, then a trestle: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final m = Metrics(
                          play, Size(room.maxWidth, room.maxHeight));
                      final guest = m.guestNear(touch.localPosition);
                      if (guest != null) {
                        _take(guest);
                        return;
                      }
                      final trestle = m.trestleNear(touch.localPosition);
                      if (trestle != null) {
                        _put(trestle);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: TableView(
                        play: play,
                        holding: holding,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
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
                          color: play.laid == widget.level.tables
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        'tables ${play.laid} of ${widget.level.tables}',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'seatings ${widget.level.ways} of 203',
                        style: const TextStyle(
                            color: Palette.guest, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'moves ${play.moves}',
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
                        : refused != null
                            ? Palette.bad
                            : play.isDone
                                ? Palette.good
                                : Palette.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              if (play.isOver)
                // The card runs long on a small phone, so it is given
                // room to scroll rather than pushing the buttons off.
                Flexible(
                  child: SingleChildScrollView(
                    child: ResultCard(
                      play: play,
                      fewest: fewest,
                      isRecord: isRecord,
                      onAgain: _again,
                      onHall: () => Navigator.of(context).pop(),
                    ),
                  ),
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
