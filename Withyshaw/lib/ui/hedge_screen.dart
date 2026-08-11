import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hedge/hedges.dart';
import '../hedge/play.dart';
import 'hedgeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One hedge: cut yours well, and let the hedger run out first.
class HedgeScreen extends StatefulWidget {
  const HedgeScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the hedger runs out of cuts, with the askings
  /// used. Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<HedgeScreen> createState() => HedgeScreenState();
}

class HedgeScreenState extends State<HedgeScreen> {
  static const hedgeKey = ValueKey('hedge');

  late Play _play;

  (int, int)? _pointing;
  var _showWorth = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showWorth => _showWorth;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(HedgeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Hedges.at(widget.number));
    _pointing = null;
    _showWorth = false;
    _hints = 0;
    _saying = _play.winnable
        ? null
        : 'This hedge sums to exactly nought, and at nought whoever cuts '
            'first loses. The first cut is yours. It is here to be felt; '
            'ask why.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? withy) {
    if (withy == null || _play.isOver) return;
    final (stalk, at) = withy;

    if (!_play.mayCut(stalk, at)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'That withy is the hedger\'s. Your bill cuts only your '
            'own, and everything above a cut falls with it.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final wasWinnable = _play.winnable;
    final next = _play.cut(stalk, at);
    setState(() {
      _play = next;
      _pointing = null;
      _showWorth = false;
      _saying = _note(next, wasWinnable);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, bool wasWinnable) {
    if (play.isOver) return null;
    final answer = 'The hedger cuts back: the hedge stands at '
        '${play.worth.said}.';
    if (wasWinnable && !play.winnable) {
      return 'That cut spent more than it took: $answer The hedge is the '
          'hedger\'s now. Take the exchange back.';
    }
    return answer;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _showWorth = false;
      _saying = null;
    });
  }

  /// Asked. A winning cut, when there is one.
  void _showMe() {
    final cut = _play.next;
    setState(() {
      _hints++;
      _showWorth = false;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The hedge is settled.';
        return;
      }
      if (cut == null) {
        _pointing = null;
        _saying = 'No cut holds the hedge from here. Cut and see what '
            'the hedger does with it.';
        return;
      }
      _pointing = cut;
      _saying = 'Cut there: what stands after keeps the sum with you, '
          'and the hedger runs out first.';
    });
  }

  /// Asked why. The worths, written on the stalks.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showWorth = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
    widget.onDone?.call(_hints).then((best) {
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
        backgroundColor: Palette.lane,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Hedgerow(
                    play: _play,
                    pointing: _pointing,
                    showWorth: _showWorth,
                    onTouch: _touched,
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

/// The line above the hedge: which hedge, and how it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final lost = !play.winnable && !(play.isOver && play.won);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the hedges',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.hedge.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isOver
                      ? (play.won
                          ? 'the hedger has nothing left to cut'
                          : 'you have nothing left to cut')
                      : lost
                          ? 'the hedger holds the hedge'
                          : 'your cut',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver && play.won
                        ? Palette.good
                        : lost
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'worth ${play.worth.said}',
            style: TextStyle(
              color: lost ? Palette.bad : Palette.ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The hedgerow itself.
class _Hedgerow extends StatelessWidget {
  const _Hedgerow({
    required this.play,
    required this.pointing,
    required this.showWorth,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showWorth;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.withyAt(touch.localPosition)),
            child: CustomPaint(
              key: HedgeScreenState.hedgeKey,
              size: size,
              painter: HedgeView(
                play: play,
                pointing: pointing,
                showWorth: showWorth,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the hedge: what the game has to say, and what else can be done.
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
                color: Palette.gate,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap one of your blue withies to cut it: everything '
                        'above falls. The hedger cuts back. Whoever '
                        'cannot cut has lost the hedge.',
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
                color: Palette.gate,
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
