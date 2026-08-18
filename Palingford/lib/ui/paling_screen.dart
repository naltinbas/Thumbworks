import 'package:flutter/material.dart';

import '../best.dart';
import '../paling/level.dart';
import '../paling/play.dart';
import '../paling/rules.dart';
import 'palette.dart';
import 'palingview.dart';
import 'result_card.dart';

/// One ask, the fence laid to it.
class PalingScreen extends StatefulWidget {
  const PalingScreen({super.key, required this.level});

  final Level level;

  @override
  State<PalingScreen> createState() => PalingScreenState();
}

class PalingScreenState extends State<PalingScreen> {
  late Play play;

  /// The paling the show-me wants lifted and the gap it wants it in, or null.
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

  void _touch(Offset where, Size room) {
    if (play.isOver) return;
    final m = Metrics(play, room);
    if (play.held == null) {
      final at = m.palingUnder(where);
      if (at == null) {
        setState(() {
          pointing = null;
          refused = 'That is sky. Tap a paling to lift it out.';
        });
        return;
      }
      setState(() {
        play = play.take(at);
        pointing = null;
        refused = null;
      });
      return;
    }
    final gap = m.gapUnder(where) ?? play.held!;
    final was = play;
    setState(() {
      play = play.slide(gap);
      pointing = null;
      refused = null;
    });
    if (play.moves == was.moves) return;
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

  /// What the fence says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return play.pointed(aim);
    final held = refused;
    if (held != null) return held;
    if (play.gaveUp) {
      return 'Nine tags will not go round ten palings.';
    }
    if (play.isDone) return 'As asked.';
    if (play.inHand != null) {
      return 'The paling ${play.inHand} tall is in hand. Tap the ground where '
          'it is to go.';
    }
    final level = widget.level;
    if (level.matched) {
      return play.climb == play.drop
          ? 'Both runs are ${play.climb} long.'
          : 'The climb runs ${play.climb} and the drop runs ${play.drop}.';
    }
    final over = <String>[
      if (play.climb > level.climbCap) 'the climb runs ${play.climb}',
      if (play.drop > level.dropCap) 'the drop runs ${play.drop}',
    ];
    return over.isEmpty
        ? 'Both runs are inside the limits.'
        : '${over.join(' and ')}, which is too far.';
  }

  Widget _chip(String words, Color edge, Color ink) => Chip(
        backgroundColor: Palette.board,
        side: BorderSide(color: edge),
        label: Text(words, style: TextStyle(color: ink, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final climbOk = level.matched
        ? play.climb == play.drop
        : play.climb <= level.climbCap;
    final dropOk =
        level.matched ? play.climb == play.drop : play.drop <= level.dropCap;
    // A limit is only worth showing on a chip when the ask really sets one.
    // The matched fence sets none, so its chips read the runs and nothing
    // more, and their edges light when the two come out level.
    final climbLimited = level.climbCap < Rules.palings;
    final dropLimited = level.dropCap < Rules.palings;
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.ink,
        title: Text(level.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Lift a paling and slide it in elsewhere: ${level.task}.',
                style: const TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, room) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (touch) => _touch(touch.localPosition,
                      Size(room.maxWidth, room.maxHeight)),
                  child: CustomPaint(
                    key: const Key('board'),
                    painter: PalingView(
                      play: play,
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
                  _chip(
                    'climb ${play.climb}'
                    '${climbLimited ? ' of ${level.climbCap}' : ''}',
                    climbOk && (climbLimited || level.matched)
                        ? Palette.good
                        : Palette.line,
                    climbOk ? Palette.climb : Palette.ink,
                  ),
                  _chip(
                    'drop ${play.drop}'
                    '${dropLimited ? ' of ${level.dropCap}' : ''}',
                    dropOk && (dropLimited || level.matched)
                        ? Palette.good
                        : Palette.line,
                    dropOk ? Palette.drop : Palette.ink,
                  ),
                  _chip('moves ${play.moves}', Palette.line, Palette.inkDim),
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
              // The card runs long on a small phone, so it is given room to
              // scroll rather than pushing the buttons off.
              Flexible(
                child: SingleChildScrollView(
                  child: ResultCard(
                    play: play,
                    fewest: fewest,
                    isRecord: isRecord,
                    onAgain: _again,
                    onFence: () => Navigator.of(context).pop(),
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
}
