import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../score/play.dart';
import '../score/rings.dart';
import 'palette.dart';
import 'result_card.dart';
import 'scoreview.dart';

/// One ring: find every start the walk never grounds from.
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the settling, with the tries taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int tries)? onDone;

  @override
  State<ScoreScreen> createState() => ScoreScreenState();
}

class ScoreScreenState extends State<ScoreScreen> {
  static const ringKey = ValueKey('ring');

  late Play _play;

  int? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ScoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rings.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.ring.winnable
        ? null
        : 'The label has said already that this tied ring holds no '
            'good start at all. Try every one and watch each walk '
            'ground; ask why for the ledger.';
    _told = false;
    _best = false;
  }

  void _touched(int? mark) {
    if (mark == null || _play.isOver) return;

    HapticFeedback.selectionClick();
    final next = _play.tryStart(mark);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _verdict(next, mark);
    });
    if (next.isOver) _finished();
  }

  String? _verdict(Play play, int mark) {
    if (play.isOver) return null;
    if (play.shownGood) {
      return 'From mark ${mark + 1} the tally never touches the '
          'ground: good start ${play.found.length} of the '
          '${play.ring.goods} asked.';
    }
    final walk = play.shownWalk;
    var step = 0;
    while (walk[step] > 0) {
      step++;
    }
    return 'From mark ${mark + 1} the tally touches the ground at '
        'step ${step + 1}: the walk is drawn below, the dip '
        'marked.';
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The start past the ebb, or the next good one.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The ring is settled.';
        return;
      }
      final start = _play.next;
      if (start == null) {
        _pointing = null;
        _saying = 'There is nothing to show: this ring runs '
            'nothing ahead, so no start of any kind stays off the '
            'ground. Ask why instead.';
        return;
      }
      _pointing = start;
      _saying = 'Try mark ${start + 1}: it sits just past the '
          'tally\'s last lowest ebb, and that start is good '
          'whenever any start is.';
    });
  }

  /// Asked why. The three voices in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.isDone) {
      widget.onDone?.call(_play.tried.length).then((best) {
        if (mounted && best) setState(() => _best = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: LayoutBuilder(
                    builder: (context, room) {
                      final size = Size(room.maxWidth, room.maxHeight);
                      final metrics = Metrics(_play, size);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (touch) => _touched(
                            metrics.markUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: ScoreScreenState.ringKey,
                          size: size,
                          painter: ScoreView(
                            play: _play,
                            pointing: _pointing,
                            labels:
                                const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_play.isOver)
                ResultCard(
                  play: _play,
                  best: _best,
                  hints: _hints,
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

/// The line above the ring: which one, and how the finding stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.ring.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rings',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ring.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isDone
                      ? 'every good start is found'
                      : play.gaveUp
                          ? 'every start grounded, as the label '
                              'said'
                          : dead
                              ? '${play.ring.task}: there is none '
                                  'to find'
                              : play.ring.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.gaveUp
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.found.length} of ${play.ring.goods}',
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Under the ring: what the game has to say, and what else can be
/// done.
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
                color: Palette.panel,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a mark to start the walk there: the tally '
                        'runs the whole ring and is drawn below. A '
                        'good start never touches the ground.',
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
                color: Palette.panel,
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
