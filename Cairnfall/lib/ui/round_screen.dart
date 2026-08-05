import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../stones/cairn.dart';
import '../stones/play.dart';
import '../stones/rounds.dart';
import '../stones/worth.dart';
import 'palette.dart';
import 'pile.dart';
import 'result_card.dart';

/// One round: take stones off the cairns, and take the last one.
class RoundScreen extends StatefulWidget {
  const RoundScreen({
    super.key,
    required this.number,
    required this.worth,
    required this.onLeave,
    required this.onNext,
    this.onOver,
    this.showWorth = false,
    this.theirPause = const Duration(milliseconds: 750),
  });

  final int number;

  /// What every cairn is worth. Worked out once by whoever opened the app.
  final Worth worth;

  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once when the round ends. Answers whether that was the first time
  /// it has been won without a wrong move.
  final Future<bool> Function({required bool win, required int wrong})? onOver;

  final bool showWorth;

  /// How long the other player takes over a move, so it can be watched.
  final Duration theirPause;

  @override
  State<RoundScreen> createState() => RoundScreenState();
}

class RoundScreenState extends State<RoundScreen> {
  late Round _round;
  late Play _play;

  /// Which cairn is being taken from, or -1.
  var _picked = -1;

  var _showWorth = false;
  var _said = '';

  /// How many of the player's moves threw a won position away.
  var _wrong = 0;
  var _clean = false;
  var _told = false;
  Timer? _theirTurn;

  Round get round => _round;
  Play get play => _play;
  int get picked => _picked;
  bool get showWorth => _showWorth;
  String get said => _said;
  int get wrong => _wrong;
  bool get theirs => _play.toMove == Who.them;

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
    _play = Play(cairns: _round.cairns, toMove: Who.you);
    _picked = -1;
    _showWorth = widget.showWorth;
    _said = 'Your move.';
    _wrong = 0;
    _clean = false;
    _told = false;
    _theirTurn?.cancel();
  }

  @override
  void dispose() {
    _theirTurn?.cancel();
    super.dispose();
  }

  void _pick(int at) {
    if (theirs || _play.isOver || _play.cairns[at].isGone) return;
    setState(() => _picked = _picked == at ? -1 : at);
  }

  void _take(int stones) {
    if (theirs || _play.isOver || _picked < 0) return;

    // Whether the move throws the round away. Only worth counting when there
    // was something to throw: from a position that is already lost, every
    // move is as bad as every other and calling one of them a mistake would
    // be a lie.
    final couldWin = widget.worth.ofAll(_play.cairns) != 0;
    final next = _play.after(Take(_picked, stones));
    final threwItAway = couldWin && widget.worth.ofAll(next.cairns) != 0;

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _picked = -1;
      if (threwItAway) _wrong++;
      _said = threwItAway ? 'Taken. That leaves them a way to win.' : 'Taken.';
    });
    _after();
  }

  void _after() {
    if (_play.isOver) {
      _finished();
      return;
    }
    if (theirs) _theirMove();
  }

  /// The other player, which is not an opponent so much as the arithmetic.
  ///
  /// It takes the move that leaves nothing to be had whenever there is one.
  /// There is nothing to tune and no difficulty to pick: from a position that
  /// can be won it wins, and from one that cannot it waits for a mistake.
  void _theirMove() {
    _theirTurn?.cancel();
    _theirTurn = Timer(widget.theirPause, () {
      if (!mounted || _play.isOver || !theirs) return;
      final move = _play.bestMove(widget.worth);
      setState(() {
        _play = _play.after(move);
        _said =
            'They took ${move.stones} '
            '${move.stones == 1 ? 'stone' : 'stones'} off the '
            '${_round.cairns[move.cairn].rule.name} cairn.';
      });
      _after();
    });
  }

  void _finished() {
    _theirTurn?.cancel();
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onOver?.call(win: _play.won == Who.you, wrong: _wrong).then((clean) {
      if (mounted && clean) setState(() => _clean = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final worth = widget.worth.ofAll(_play.cairns);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            children: [
              _Ledger(
                round: _round,
                play: _play,
                showWorth: _showWorth,
                onLeave: widget.onLeave,
                onShowWorth: () => setState(() => _showWorth = !_showWorth),
              ),
              Expanded(
                // Centred rather than piled at the top: a row of cairns and a
                // line of text is a third of the screen, and it reads as a
                // table rather than as the top of a list.
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var at = 0; at < _play.cairns.length; at++)
                              if (!_play.cairns[at].isGone)
                                Pile(
                                  cairn: _play.cairns[at],
                                  picked: at == _picked,
                                  worth: _showWorth
                                      ? widget.worth.of(_play.cairns[at])
                                      : null,
                                  onTap: theirs ? null : () => _pick(at),
                                ),
                          ],
                        ),
                        if (_showWorth) ...[
                          const SizedBox(height: 14),
                          _Total(worth: worth),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          _said,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Palette.ink,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_play.isOver)
                ResultCard(
                  round: _round,
                  play: _play,
                  wrong: _wrong,
                  clean: _clean,
                  onAgain: () => setState(_set),
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Takes(
                  cairn: _picked < 0 ? null : _play.cairns[_picked],
                  waiting: theirs,
                  onTake: _take,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the cairns: which round, and whether the numbers are on.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.round,
    required this.play,
    required this.showWorth,
    required this.onLeave,
    required this.onShowWorth,
  });

  final Round round;
  final Play play;
  final bool showWorth;
  final VoidCallback onLeave;
  final VoidCallback onShowWorth;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 2, 14, 2),
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
                play.isOver
                    ? 'over'
                    : play.toMove == Who.you
                    ? 'your move'
                    : 'their move',
                style: TextStyle(
                  color: play.toMove == Who.you
                      ? Palette.going
                      : Palette.inkDim,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: showWorth
              ? 'hide what they are worth'
              : 'show what they '
                    'are worth',
          child: GestureDetector(
            onTap: onShowWorth,
            child: Row(
              children: [
                Icon(
                  showWorth
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 17,
                  color: showWorth ? Palette.lichen : Palette.inkDim,
                ),
                const SizedBox(width: 6),
                Text(
                  'the numbers',
                  style: TextStyle(
                    color: showWorth ? Palette.lichen : Palette.inkDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// What the whole row comes to, and what that means.
class _Total extends StatelessWidget {
  const _Total({required this.worth});

  final int worth;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(
      color: Palette.moor,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: worth == 0 ? Palette.bad : Palette.lichen,
        width: 1.1,
      ),
    ),
    child: Column(
      children: [
        Text(
          'all of them together: $worth',
          style: TextStyle(
            color: worth == 0 ? Palette.bad : Palette.lichen,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          worth == 0
              ? 'Nothing. Whoever moves from here loses, played properly.'
              : 'Not nothing, so there is a move that wins: the one that '
                    'makes this nought.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.inkDim,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

/// How many to take off the cairn that has been picked.
class _Takes extends StatelessWidget {
  const _Takes({
    required this.cairn,
    required this.waiting,
    required this.onTake,
  });

  final Cairn? cairn;
  final bool waiting;
  final ValueChanged<int> onTake;

  @override
  Widget build(BuildContext context) {
    final takes = cairn?.takes ?? const <int>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Palette.moor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            waiting
                ? 'They are thinking.'
                : cairn == null
                ? 'Tap a cairn to take from it.'
                : cairn!.rule.says,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Palette.inkDim,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (takes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final take in takes)
                  Semantics(
                    button: true,
                    label: 'take $take',
                    child: GestureDetector(
                      onTap: waiting ? null : () => onTake(take),
                      child: ExcludeSemantics(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Palette.ledge,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Palette.going,
                              width: 1.1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$take',
                            style: const TextStyle(
                              color: Palette.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
