import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tower/play.dart';
import '../tower/spindles.dart';
import 'palette.dart';
import 'result_card.dart';
import 'towerview.dart';

/// One tower: raise it home, round by round.
class TowerScreen extends StatefulWidget {
  const TowerScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at home, with the moves made. Answers whether that
  /// beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<TowerScreen> createState() => TowerScreenState();
}

class TowerScreenState extends State<TowerScreen> {
  static const benchKey = ValueKey('bench');

  late Play _play;

  var _lifted = -1;
  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get lifted => _lifted;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(TowerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Spindles.at(widget.number));
    _lifted = -1;
    _pointing = null;
    _hints = 0;
    final wager = _play.spindle.wager;
    _saying = wager == null
        ? null
        : 'The house wagers you cannot raise this tower in $wager. '
            'The walk of every board says the house is safe; play it '
            'out, and ask why for the words.';
    _told = false;
    _best = false;
  }

  void _touched(int spindle) {
    if (spindle < 0 || _play.isHome) return;

    HapticFeedback.selectionClick();
    if (_lifted < 0) {
      if (_play.topOf(spindle) == null) {
        setState(() {
          _saying = 'That spindle is bare: lift from one holding a '
              'round.';
        });
        return;
      }
      setState(() {
        _lifted = spindle;
        _pointing = null;
      });
      return;
    }
    if (_lifted == spindle) {
      setState(() => _lifted = -1);
      return;
    }

    if (!_play.mayMove(_lifted, spindle)) {
      setState(() {
        _saying = 'A round never rests on a smaller one.';
      });
      return;
    }

    final could = _play.fewestFromHere;
    final next = _play.move(_lifted, spindle);
    setState(() {
      _play = next;
      _lifted = -1;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isHome) _finished();
  }

  String? _note(Play play, int could) {
    if (play.isHome) return null;
    final now = play.fewestFromHere;
    if (now > could) {
      return 'That move wandered: the fewest from here rose to $now. '
          'Back takes it off the count.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _lifted = -1;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The move the walk steps nearer home with.
  void _showMe() {
    final move = _play.next;
    setState(() {
      _hints++;
      _lifted = -1;
      if (move == null) {
        _pointing = null;
        _saying = 'The tower stands home.';
        return;
      }
      _pointing = move;
      _saying = 'Lift from the ${_name(move.$1)} spindle to the '
          '${_name(move.$2)}: the walk has measured every board, and '
          'this steps one nearer.';
    });
  }

  String _name(int spindle) => const [
        'first',
        'second',
        'third',
        'fourth',
      ][spindle];

  /// Asked why. The reckonings and the walk, in words.
  void _why() {
    setState(() {
      _hints++;
      _lifted = -1;
      _pointing = null;
      _saying = whyWords(_play);
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
        backgroundColor: Palette.bench,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Bench(
                    play: _play,
                    lifted: _lifted,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isHome)
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

/// The line above the bench: which job, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final wager = play.spindle.wager;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the towers',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.spindle.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isHome
                      ? 'the tower stands home'
                      : wager != null
                          ? 'the wager asks $wager; the floor is '
                              '${play.spindle.fewest}'
                          : '${play.fewestFromHere} moves from home',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isHome
                        ? Palette.good
                        : wager != null
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} moved',
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

/// The bench itself.
class _Bench extends StatelessWidget {
  const _Bench({
    required this.play,
    required this.lifted,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int lifted;
  final (int, int)? pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.spindleAt(touch.localPosition)),
            child: CustomPaint(
              key: TowerScreenState.benchKey,
              size: size,
              painter: TowerView(
                play: play,
                lifted: lifted,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
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
                color: Palette.panel,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a spindle to lift its top round, another to '
                        'set it down. A round never rests on a '
                        'smaller one. Raise the whole tower on the '
                        'last spindle.',
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
