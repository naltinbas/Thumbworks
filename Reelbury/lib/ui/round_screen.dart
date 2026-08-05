import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../reel/play.dart';
import '../reel/rounds.dart';
import 'floor.dart';
import 'palette.dart';
import 'result_card.dart';

/// One round: pair the two sides up so that nobody wants to swap.
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

  /// Called once, the first time a round is paired up, with the changes it
  /// took. Answers whether that beat what was written down before.
  final Future<bool> Function(int changes)? onDone;

  @override
  State<RoundScreen> createState() => RoundScreenState();
}

class RoundScreenState extends State<RoundScreen> {
  static const floorKey = ValueKey('floor');

  late Round _round;
  late Play _play;

  /// A caller waiting for a partner, or -1.
  var _holding = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Round get round => _round;
  Play get play => _play;
  int get holding => _holding;
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
    _holding = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// Somebody tapped. A caller is picked up and waits; a dancer pairs with
  /// whoever is waiting, or is let go of if they are already in that couple.
  void _touched(bool caller, int who) {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();

    if (caller) {
      setState(() {
        _holding = _holding == who ? -1 : who;
        _saying = _play.dancerOf(who) >= 0 && _holding == who
            ? 'Now tap somebody else for ${_round.callerName(who)}, or tap '
                '${_round.callerName(who)} again to leave it.'
            : null;
      });
      return;
    }

    if (_holding < 0) {
      final has = _play.callerOf(who);
      if (has >= 0) {
        setState(() {
          _play = _play.part(has);
          _saying = null;
        });
        return;
      }
      setState(() => _saying = 'Tap one of the callers first.');
      return;
    }

    final next = _play.pair(_holding, who);
    setState(() {
      _play = next;
      _holding = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the floor has to say.
  ///
  /// While anybody is unpaired there is nothing worth saying: every pair
  /// would rather have each other than have nobody, so pointing that out
  /// would be pointing at everybody. Once the floor is full it is the whole
  /// game, and it is said with names.
  String? _note(Play play) {
    if (play.isDone) return null;
    if (!play.isFull) return null;

    final swaps = play.blocking;
    final one = swaps.first;
    final more = swaps.length - 1;
    return '${_round.callerName(one.caller)} and '
        '${_round.dancerName(one.dancer)} would both rather have each other'
        '${more == 0 ? '.' : ', and there ${more == 1 ? 'is' : 'are'} $more '
            'more like that.'}';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _holding = -1;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Names one couple of the pairing that holds. The game has that
  /// pairing because asking in turn always finds one, whatever the lists
  /// say.
  void _showMe() {
    if (_play.isDone) return;
    final answer = _play.answer;
    setState(() {
      _hints++;
      for (var caller = 0; caller < _play.count; caller++) {
        if (_play.dancerOf(caller) == answer[caller]) continue;
        _play = _play.pair(caller, answer[caller]);
        _holding = -1;
        _saying = '${_round.callerName(caller)} and '
            '${_round.dancerName(answer[caller])}. That couple is in the '
            'pairing that holds.';
        if (_play.isDone) _finished();
        return;
      }
      _saying = 'Everybody is where they should be.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.changes).then((best) {
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
              _Ledger(round: _round, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: _Floor(
                    play: _play,
                    holding: _holding,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  round: _round,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  play: _play,
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

/// The line above the floor: which round, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.round,
    required this.play,
    required this.onLeave,
  });

  final Round round;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final swaps = play.isFull ? play.blocking.length : 0;

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
                  round.name,
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
                      ? 'nobody wants to swap'
                      : play.isFull
                          ? '$swaps ${swaps == 1 ? 'pair' : 'pairs'} would '
                              'rather swap'
                          : '${play.count - play.paired} still to pair',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : swaps > 0
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.paired} / ${play.count}',
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

/// The hall itself.
class _Floor extends StatelessWidget {
  const _Floor({
    required this.play,
    required this.holding,
    required this.onTouch,
  });

  final Play play;
  final int holding;
  final void Function(bool caller, int who) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play.count, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final who = metrics.whoIs(touch.localPosition);
              if (who != null) onTouch(who.$1, who.$2);
            },
            child: CustomPaint(
              key: RoundScreenState.floorKey,
              size: size,
              painter: Floor(
                play: play,
                holding: holding,
                showSwaps: play.isFull,
                names: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                lists: const TextStyle(
                  color: Palette.inkDim,
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      );
}

/// Under the floor: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.play,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final Play play;
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
                color: Palette.floor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.board, width: 1.1),
              ),
              child: Text(
                saying ??
                    (play.isFull
                        ? 'Everybody is paired. Now look for two who would '
                            'rather have each other.'
                        : 'Tap a caller, then somebody to dance with. The '
                            'letters are who they would have, best first.'),
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
                color: Palette.floor,
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
