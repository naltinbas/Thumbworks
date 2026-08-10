import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mill/fewest.dart';
import '../mill/play.dart';
import '../mill/yards.dart';
import 'palette.dart';
import 'result_card.dart';
import 'yardview.dart';

/// One yard: get the stack to the far staddle in the fewest moves.
class YardScreen extends StatefulWidget {
  const YardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time the stack is home, with the moves it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  static const yardKey = ValueKey('yard');

  static final _tables = <int, Moves>{};

  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;
  var _saidHalfWay = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(YardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    final yard = Yards.at(widget.number);
    _play = Play.of(
      yard,
      _tables.putIfAbsent(yard.stones, () => Moves(yard.stones)),
    );
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
    _saidHalfWay = false;
  }

  void _touched(int staddle) {
    if (staddle < 0 || _play.isDone) return;

    final before = _play;
    final next = _play.touch(staddle);
    if (identical(next, before)) {
      setState(() {
        _pointing = -1;
        _saying = before.lifted < 0
            ? 'That staddle is bare.'
            : 'A bigger stone never sits on a smaller.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(before, next);
    });
    if (next.isDone) _finished();
  }

  /// What the yard has to say after a stone lands.
  String? _note(Play before, Play play) {
    if (play.isDone || play.made == before.made) return null;

    if (!_saidHalfWay && play.biggestHome && play.made <= play.yard.fewest) {
      _saidHalfWay = true;
      final made = play.made;
      final left = play.left;
      return 'The big stone is home on move $made, with $left still to go: '
          'the little ones must all come back on top of it.';
    }

    final could = play.couldFinishIn;
    if (could > play.yard.fewest) {
      return 'The fewest this can be done in now is $could, which is '
          '${could - play.yard.fewest} more than the ${play.yard.fewest} it '
          'takes.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  /// Asked. The move to make next on a shortest way from where the stones
  /// stand.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = 'The stack is home.';
        return;
      }
      final (from, to) = next;
      if (_play.lifted >= 0 && _play.lifted != from) {
        _play = _play.touch(_play.lifted);
      }
      _pointing = _play.lifted == from ? to : from;
      _saying = _play.lifted == from
          ? 'Set it down on the ${_name(to)}.'
          : 'Lift the top of the ${_name(from)}. ${_play.left - 1} more '
              'after this one.';
    });
  }

  /// Asked why. The doubling argument, told at whatever stage the yard is in.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final stones = _play.yard.stones;
      final smaller = Moves.doublingSays(stones - 1);
      _saying = 'For the biggest stone to move at all, the $smaller moves of '
          'the ${stones - 1} smaller stones have to be spent getting them '
          'onto one other staddle. Then it crosses, and they must all come '
          'back on top: $smaller more. Twice $smaller and one is '
          '${_play.yard.fewest}, and the same doubling holds all the way '
          'down, which is why one more stone always doubles the work and one '
          'more.';
    });
  }

  String _name(int staddle) => switch (staddle) {
        0 => 'first staddle',
        1 => 'middle staddle',
        _ => 'far staddle',
      };

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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _YardMap(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
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

/// The line above the yard: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > play.yard.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the yards',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.yard.name,
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
                      ? 'every stone on the far staddle'
                      : play.biggestHome
                          ? 'the big stone is across'
                          : 'get the stack to the far staddle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} / ${play.yard.fewest}',
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

/// The yard itself.
class _YardMap extends StatelessWidget {
  const _YardMap({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.staddleAt(touch.localPosition)),
            child: CustomPaint(
              key: YardScreenState.yardKey,
              size: size,
              painter: YardView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the yard: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a staddle to lift its top stone, and another to set '
                        'it down. A bigger stone never sits on a smaller.',
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
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 9),
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
