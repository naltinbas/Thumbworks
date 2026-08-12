import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../wall/pitches.dart';
import '../wall/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'wallview.dart';

/// One pitch: raise the wall to the asked height.
class WallScreen extends StatefulWidget {
  const WallScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the coping, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<WallScreen> createState() => WallScreenState();
}

class WallScreenState extends State<WallScreen> {
  static const wallKey = ValueKey('wall');

  late Play _play;

  int? _pointing;
  (int, int)? _doubled;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int? get pointing => _pointing;
  (int, int)? get doubled => _doubled;
  int get hints => _hints;
  String? get saying => _saying;

  bool get isOver => _play.isDone || _play.pennedIn;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Pitches.at(widget.number));
    _pointing = null;
    _doubled = null;
    _hints = 0;
    _saying = _play.pitch.winnable
        ? null
        : 'Four courses are asked, and the label has said already '
            'that two kinds die at the third. Lay the wall out and '
            'watch every fourth course double; ask why for the '
            'sweep.';
    _told = false;
    _best = false;
  }

  void _lay(int kind) {
    if (isOver) return;

    final run = _play.doubledBy(kind);
    if (run != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _doubled = run;
        _pointing = null;
        _saying = 'That course lays a run of ${run.$2} twice over: '
            'the doubled block is marked on the wall, and the rule '
            'refuses it.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.lay(kind);
    setState(() {
      _play = next;
      _pointing = null;
      _doubled = null;
      _saying = null;
    });
    if (next.isDone || next.pennedIn) _finished();
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _doubled = null;
      _saying = null;
    });
  }

  /// Asked. A kind that keeps the height in reach.
  void _showMe() {
    setState(() {
      _hints++;
      _doubled = null;
      if (isOver) {
        _pointing = null;
        _saying = 'The wall is done with.';
        return;
      }
      final kind = _play.next;
      if (kind == null) {
        _pointing = null;
        _saying = _play.pitch.winnable
            ? 'No course of any kind keeps the height in reach: '
                'the walk has grown them all. Back is the only way '
                'up.'
            : 'There is nothing to show: no wall of two kinds '
                'climbs to four, and the sweep has laid them all. '
                'Ask why instead.';
        return;
      }
      _pointing = kind;
      _saying = 'Lay ${Palette.kindNames[kind].toLowerCase()}: the '
          'walk has grown every wall from there, and the height '
          'stays in reach.';
    });
  }

  /// Asked why. The rule and the sweep in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _doubled = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.isDone) {
      widget.onDone?.call(_hints).then((best) {
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
                    builder: (context, room) => CustomPaint(
                      key: WallScreenState.wallKey,
                      size: Size(room.maxWidth, room.maxHeight),
                      painter: WallView(
                        play: _play,
                        doubled: _doubled,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                ),
              ),
              if (isOver)
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
                  play: _play,
                  saying: _saying,
                  pointing: _pointing,
                  onLay: _lay,
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

/// The line above the wall: which pitch, and how high it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.pitch.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the pitches',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.pitch.name,
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
                      ? 'the wall stands at its height'
                      : play.pennedIn
                          ? dead
                              ? 'penned at three, as the label said'
                              : 'penned in: every course doubles'
                          : dead
                              ? '${play.pitch.task}: no wall ever '
                                  'has'
                              : play.pitch.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.pennedIn
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.courses.length} of ${play.pitch.height}',
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

/// Under the wall: the stone heaps, what the game has to say, and
/// what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.play,
    required this.saying,
    required this.pointing,
    required this.onLay,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final Play play;
  final String? saying;
  final int? pointing;
  final ValueChanged<int> onLay;
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
                    'Lay a course from one of the heaps. No run of '
                        'courses, short or long, may be laid twice '
                        'over.',
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
                for (var kind = 0; kind < play.pitch.kinds; kind++) ...[
                  if (kind > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _HeapButton(
                      kind: kind,
                      lit: pointing == kind,
                      onTap: () => onLay(kind),
                    ),
                  ),
                ],
              ],
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

class _HeapButton extends StatelessWidget {
  const _HeapButton({
    required this.kind,
    required this.lit,
    required this.onTap,
  });

  final int kind;
  final bool lit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Lay ${Palette.kindNames[kind].toLowerCase()}',
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lit ? Palette.shown : Palette.edge,
                  width: lit ? 2.6 : 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Palette.kinds[kind],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Palette.kindNames[kind],
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
