import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../forge/play.dart';
import '../forge/puzzles.dart';
import 'forgeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One puzzle: work every ring off the bar in the fewest moves.
class ForgeScreen extends StatefulWidget {
  const ForgeScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the bar slides free, with the moves it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<ForgeScreen> createState() => ForgeScreenState();
}

class ForgeScreenState extends State<ForgeScreen> {
  static const forgeKey = ValueKey('forge');

  late Play _play;

  var _pointing = -1;
  var _showCount = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showCount => _showCount;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ForgeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Puzzles.at(widget.number));
    _pointing = -1;
    _showCount = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int ring) {
    if (ring < 0 || _play.isFree) return;

    if (!_play.mayMove(ring)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The cords hold that ring. A ring moves only when the '
            'ring just before it is on the bar and every ring before that '
            'is off.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.move(ring);
    setState(() {
      _play = next;
      _pointing = -1;
      _showCount = false;
      _saying = _note(next);
    });
    if (next.isFree) _finished();
  }

  /// What the bench has to say after a move.
  String? _note(Play play) {
    if (play.isFree) return null;
    final could = play.couldStillBe;
    if (could > play.puzzle.fewest) {
      return 'The fewest moves this bar can still be freed in is $could, '
          '${could - play.puzzle.fewest} more than the '
          '${play.puzzle.fewest} it takes. Of the two moves the cords '
          'allow, that was the one that goes backwards.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _showCount = false;
      _saying = _note(_play);
    });
  }

  /// Asked. The one move that goes forward.
  void _showMe() {
    final ring = _play.next;
    setState(() {
      _hints++;
      _showCount = false;
      if (ring == null) {
        _pointing = -1;
        _saying = 'The bar is free.';
        return;
      }
      _pointing = ring;
      _saying = ring == 0
          ? 'The hand ring. Of the two moves the cords allow, that is the '
              'one that goes forward.'
          : 'Ring ${ring + 1} from your hand. Of the two moves the cords '
              'allow, that is the one that goes forward.';
    });
  }

  /// Asked why. The smith's figures, written over the rings.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showCount = true;
      final note = _play.puzzle.note;
      _saying = 'Write a figure over each ring, the far ring first: flip '
          'at every ring that is on, copy at every ring that is off. Read '
          'the figures as a binary number: ${_play.smithSays}. That is '
          'exactly how many moves the bar is from free, and the walk of '
          'every state there is agrees.'
          '${note == null ? '' : ' $note'}';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.made).then((best) {
      if (mounted && best) setState(() => _best = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.soot,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Forge(
                    play: _play,
                    pointing: _pointing,
                    showCount: _showCount,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isFree)
                ResultCard(
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onAgain: _again,
                  onBack: _takeBack,
                  onShowMe: _showMe,
                  onWhy: _why,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the bench: which puzzle, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = !play.isFree && play.couldStillBe > play.puzzle.fewest;
    var on = 0;
    for (var ring = 0; ring < play.puzzle.rings; ring++) {
      if (play.isOn(ring)) on++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the bench',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.puzzle.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isFree
                      ? 'the bar is free'
                      : '$on ring${on == 1 ? '' : 's'} on the bar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isFree ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} / ${play.puzzle.fewest}',
            style: TextStyle(
              color: over ? Palette.bad : Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The toy itself.
class _Forge extends StatelessWidget {
  const _Forge({
    required this.play,
    required this.pointing,
    required this.showCount,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showCount;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          // No taller than the toy is: on a tall phone an unbounded box
          // strings the cords across an acre of nothing.
          final size = Size(
            room.maxWidth,
            math.min(room.maxHeight, room.maxWidth * 0.95),
          );
          final metrics = Metrics(play, size);

          return Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (touch) =>
                    onTouch(metrics.ringUnder(touch.localPosition)),
                child: CustomPaint(
                  key: ForgeScreenState.forgeKey,
                  size: size,
                  painter: ForgeView(
                    play: play,
                    pointing: pointing,
                    showCount: showCount,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

/// Under the bench: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onBack;
  final VoidCallback onShowMe;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a bright ring to work it on or off the bar. The '
                        'first ring is always free; the cords hold the '
                        'rest. Free the bar of every ring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Back', onTap: onBack)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
