import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../round/play.dart';
import '../round/rounds_list.dart';
import 'fen.dart';
import 'palette.dart';
import 'result_card.dart';

/// One round: call at every farm and get home.
class RoundScreen extends StatefulWidget {
  const RoundScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a round comes home, with how far it was.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int furlongs)? onDone;

  @override
  State<RoundScreen> createState() => RoundScreenState();
}

class RoundScreenState extends State<RoundScreen> {
  static const fenKey = ValueKey('fen');

  late Round _round;
  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Round get round => _round;
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
  void didUpdateWidget(RoundScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _round = Rounds.at(widget.number);
    _play = Play.of(_round);
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int stop) {
    if (_play.isDone || stop < 0) return;
    if (!_play.canGoTo(stop)) {
      setState(() => _saying = stop == 0
          ? 'The yard is where the round ends. It gets there on its own.'
          : 'The cart has already called there.');
      return;
    }

    final next = _play.goTo(stop);
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the round has to say after a call.
  ///
  /// One thing, and only when it is true: that the round can no longer be as
  /// short as it might have been. The game can say that because it works out
  /// the shortest way to finish from where the cart actually is, which is a
  /// different question from the one it answered at the start.
  String? _note(Play play) {
    if (play.isDone) return null;
    final couldBe = play.gone + play.restOfIt.length;
    if (couldBe <= _round.shortest) return null;
    return 'The best this round can come home in now is $couldBe, which is '
        '${couldBe - _round.shortest} over the ${_round.shortest}.';
  }

  void _back() {
    if (_play.called.length < 2) return;
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
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at the place to call at next to finish as short as the
  /// round can still be, which is the only honest answer once a call has been
  /// made that costs something.
  void _showMe() {
    if (_play.isDone) return;
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = 'There is nowhere left to call.';
        return;
      }
      _pointing = next;
      final rest = _play.restOfIt.length;
      _saying = '${_round.stops[next].name} next. '
          '$rest furlongs to get home from here.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.length).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Fen(
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
                  canTakeBack: _play.called.length > 1,
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

/// The line above the map: which round, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final shortest = play.round.shortest;
    final over = play.isDone && play.length > shortest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rounds',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.round.name,
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
                      ? 'home, ${play.length} furlongs'
                      : '${play.left.length} still to call at, '
                          '${play.gone} driven',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone && play.isShortest
                        ? Palette.good
                        : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            play.isDone ? '${play.length} / $shortest' : '$shortest',
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
class _Fen extends StatelessWidget {
  const _Fen({
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
            onTapUp: (touch) => onTouch(metrics.stopAt(touch.localPosition)),
            child: CustomPaint(
              key: RoundScreenState.fenKey,
              size: size,
              painter: Fen(
                play: play,
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
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.ground,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.hedge, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a farm to drive there. The cart comes home to the '
                        'yard once it has called everywhere.',
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
                color: Palette.ground,
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
