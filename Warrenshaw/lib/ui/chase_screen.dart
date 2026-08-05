import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chase/maps.dart';
import '../chase/play.dart';
import '../chase/tablebase.dart';
import 'palette.dart';
import 'result_card.dart';
import 'warren_view.dart';

/// One map: corner the runner.
class ChaseScreen extends StatefulWidget {
  const ChaseScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a map is won, with the moves it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<ChaseScreen> createState() => ChaseScreenState();
}

class ChaseScreenState extends State<ChaseScreen> {
  static const mapKey = ValueKey('map');

  late Warren _warren;
  late Tablebase _table;
  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Warren get warren => _warren;
  Play get play => _play;
  Tablebase get table => _table;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ChaseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _warren = Warrens.at(widget.number);
    // Every position of the chase, settled once as the map opens. It is a
    // few hundred numbers on maps this size, so there is nothing to wait for
    // and nothing to search at run time.
    _table = Tablebase(_warren.chart);
    _play = Play.of(_warren, _table);
    _pointing = -1;
    _hints = 0;
    _saying = _warren.hopeless
        ? 'Nobody can win this one. Try, and then look at why.'
        : null;
    _told = false;
    _best = false;
  }

  void _touched(int place) {
    if (_play.isDone || place < 0) return;

    final why = _play.whyNot(place);
    if (why != null) {
      setState(() => _saying = why.says);
      return;
    }

    final next = _play.move(place);
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the chase has to say after a move.
  ///
  /// The one thing worth saying is that a move cost something, and it can be
  /// said because the table knows what the position was worth before and
  /// after. Nothing else here is worth interrupting anybody for.
  String? _note(Play play) {
    if (play.isDone) return null;
    if (_warren.hopeless) {
      return 'It keeps the far side of the ring. It always can.';
    }
    if (!play.canStillWin) {
      return 'From here it gets away for ever. Take that back.';
    }
    if (play.wasted > 0) {
      return 'That was not on any quickest way. '
          '${play.left} more from here, which is ${play.wasted} over the '
          '${_warren.par}.';
    }
    return null;
  }

  void _back() {
    if (_play.been.isEmpty) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _saying = null;
    });
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _saying = _warren.hopeless
          ? 'Nobody can win this one. Try, and then look at why.'
          : null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at the move that catches the runner soonest from where the
  /// chase actually stands — which is the only honest answer, because the
  /// moves already made change what the quickest way is.
  void _showMe() {
    if (_play.isDone) return;
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = _warren.hopeless
            ? 'There is no move that catches it, on this map, ever. '
                'Every place here has a place opposite it, so it steps '
                'across and waits.'
            : 'From here it gets away. Take some moves back.';
        return;
      }
      _pointing = next;
      _saying = 'Go to the ${_play.chart.places[next].name}. '
          '${_play.left} more from here.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.moves).then((best) {
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
              _Ledger(warren: _warren, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Map(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  warren: _warren,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canTakeBack: _play.been.isNotEmpty,
                  onBack: _back,
                  onAgain: _again,
                  onShowMe: _showMe,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the map: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.warren,
    required this.play,
    required this.onLeave,
  });

  final Warren warren;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final par = warren.par;
    final over = par != null && play.moves > par;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the maps',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warren.name,
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
                      ? 'caught'
                      : warren.hopeless
                          ? 'it cannot be caught here'
                          : play.canStillWin
                              ? '${play.left} more from here'
                              : 'it gets away from here',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : play.canStillWin || warren.hopeless
                            ? Palette.inkDim
                            : Palette.bad,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            par == null ? '${play.moves}' : '${play.moves} / $par',
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

/// The map itself.
class _Map extends StatelessWidget {
  const _Map({
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
          final metrics = Metrics(play.chart, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.whereIs(touch.localPosition)),
            child: CustomPaint(
              key: ChaseScreenState.mapKey,
              size: size,
              painter: WarrenView(
                play: play,
                canGo: play.canGo,
                pointing: pointing,
                labels: const TextStyle(
                  color: Palette.inkDim,
                  fontFamily: 'Roboto',
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      );
}

/// Under the map: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canTakeBack,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final bool canTakeBack;
  final VoidCallback onBack;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Palette.field,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.hedge, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a place along a path, or stay where you are. It moves '
                        'when you do.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Button(
                    label: 'Take back',
                    dead: !canTakeBack,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(
                    label: 'Again',
                    dead: !canTakeBack,
                    onTap: onAgain,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.dead,
    required this.onTap,
  });

  final String label;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.field,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.hedge : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: dead ? Palette.inkDim : Palette.ink,
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
