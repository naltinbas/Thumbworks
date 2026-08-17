import 'package:flutter/material.dart';

import '../best.dart';
import '../flit/level.dart';
import '../flit/play.dart';
import '../flit/rules.dart';
import 'flitview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the lane laid to it.
class FlitScreen extends StatefulWidget {
  const FlitScreen({super.key, required this.level});

  final Level level;

  @override
  State<FlitScreen> createState() => FlitScreenState();
}

class FlitScreenState extends State<FlitScreen> {
  late Play play;

  /// The two tenants the show-me wants swapped, or null.
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

  void _tap(int tenant) {
    if (play.isOver) return;
    final was = play;
    setState(() {
      play = play.tap(tenant);
      pointing = null;
      refused = null;
    });
    if (identical(play, was) || play.swaps == was.swaps) return;
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.swaps).then((record) {
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
      refused = 'A cottage stays where it is. Tap a tenant, then tap the '
          'tenant they are to swap with.';
    });
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
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
      pointing = null;
      refused = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the lane says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.held != null) {
      return 'Tenant ${Rules.letter(play.held!)} is ready. Tap whoever they '
          'are to swap with.';
    }
    if (play.gaveUp) {
      final firm = play.level.firmLane;
      final named = Rules.topped(play.orders, firm).map(Rules.letter).join(', ');
      return 'In the firm lane ${Rules.write(firm)}, tenants $named already '
          'have the cottage they want most.';
    }
    if (play.isDone) return 'As asked.';
    final beaters = play.beaters;
    if (beaters != null) {
      return 'Tenants ${beaters.map(Rules.letter).join(', ')} could all do '
          'better by trading among themselves.';
    }
    final nudgers = play.nudgers;
    if (nudgers != null) {
      return 'Tenants ${nudgers.map(Rules.letter).join(', ')} could better one '
          'of their own without setting another back.';
    }
    return 'No group of tenants can better this lane.';
  }

  /// What the board draws. Once a hopeless ask has been admitted it
  /// shows the firm lane instead of wherever the player left off, since
  /// that is the lane the card is talking about.
  Play get shown => play.gaveUp
      ? Play.standing(widget.level, widget.level.firmLane)
      : play;

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
                  'Tap two tenants to swap cottages: ${widget.level.task}.',
                  style: const TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (touch) {
                      final who = Metrics(
                              play, Size(room.maxWidth, room.maxHeight))
                          .tenantNear(touch.localPosition);
                      if (who != null) {
                        _tap(who);
                      } else {
                        _miss();
                      }
                    },
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: FlitView(
                        play: shown,
                        pointing: pointing,
                        showWhyNot: play.gaveUp,
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
                          color: play.beaters == null
                              ? Palette.good
                              : Palette.line),
                      label: Text(
                        play.beaters == null ? 'unbeaten' : 'beaten',
                        style: TextStyle(
                          color: play.beaters == null
                              ? Palette.best
                              : Palette.worst,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'lands ${widget.level.ways} of 24',
                        style: const TextStyle(
                            color: Palette.ink, fontSize: 13),
                      ),
                    ),
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.line),
                      label: Text(
                        'swaps ${play.swaps}',
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
                            ? Palette.worst
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
                      onLane: () => Navigator.of(context).pop(),
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
