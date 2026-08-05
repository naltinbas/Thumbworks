import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/odds.dart';
import '../game/play.dart';
import '../game/review.dart';
import '../game/rules.dart';
import 'die.dart';
import 'odds_strip.dart';
import 'palette.dart';
import 'result_card.dart';
import 'score_bar.dart';

/// A game: your throws against theirs.
class TableScreen extends StatefulWidget {
  const TableScreen({
    super.key,
    required this.odds,
    required this.onLeave,
    required this.onAgain,
    this.onOver,
    this.dice,
    this.opensWith,
    this.showOdds = false,
    this.theirPause = const Duration(milliseconds: 850),
  });

  final Odds odds;
  final VoidCallback onLeave;
  final VoidCallback onAgain;

  /// Called once when the game ends. Answers whether that was the sharpest
  /// game yet.
  final Future<bool> Function({required bool win, required double sharpness})?
      onOver;

  /// Where the dice come from. A test hands in one that has been told what to
  /// throw.
  final Random? dice;

  /// A position to start from. Only a test or a screenshot passes this.
  final Play? opensWith;

  final bool showOdds;

  /// How long the other player takes over a move, so it can be watched.
  final Duration theirPause;

  @override
  State<TableScreen> createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {
  late Play _play;
  late Review _review;
  late Random _dice;

  var _showOdds = false;
  var _said = '';
  var _told = false;
  var _sharpest = false;
  Timer? _theirTurn;

  Play get play => _play;
  Review get review => _review;
  bool get showOdds => _showOdds;
  String get said => _said;
  bool get theirs => _play.toMove == Who.them;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    _dice = widget.dice ?? Random();
    setState(() {
      _play = widget.opensWith ?? const Play.start();
      _review = Review(widget.odds);
      _showOdds = widget.showOdds;
      _said = 'Your throw.';
      _told = false;
      _sharpest = false;
    });
    if (_play.toMove == Who.them) _theirMove();
  }

  @override
  void dispose() {
    _theirTurn?.cancel();
    super.dispose();
  }

  /// What just happened, in a line.
  String _wordsFor(Move move, Rolled rolled, {required bool mine}) {
    final who = mine ? 'You' : 'They';
    if (rolled.wipes) return '$who threw two ones. Everything goes.';
    if (rolled.bust) return '$who threw a one. The turn goes.';
    if (rolled.doubled) {
      return '$who threw a pair of ${rolled.faces.first}s, worth ${rolled.paid}, '
          'double.';
    }
    if (move == Move.two) return '$who threw $rolled. ${rolled.paid}.';
    return '$who threw a ${rolled.faces.single}.';
  }

  void _take(Move move) {
    if (_play.isOver || theirs) return;
    _review.note(_play, move);

    if (move == Move.bank) {
      setState(() {
        _play = _play.bank();
        _said = 'Banked. You stand on ${_play.yours}.';
      });
      HapticFeedback.selectionClick();
      _after();
      return;
    }

    final rolled = Rolled.from(move, _dice);
    setState(() {
      _play = _play.took(move, rolled);
      _said = _wordsFor(move, rolled, mine: true);
    });
    if (rolled.bust) HapticFeedback.mediumImpact();
    _after();
  }

  void _after() {
    if (_play.isOver) {
      _finished();
      return;
    }
    if (theirs) _theirMove();
  }

  /// The other player, which is not an opponent so much as the answer.
  ///
  /// It plays the move the table says wins most often, every time. There is
  /// nothing to tune and no difficulty to pick: this is what perfect play
  /// looks like, and the only question is how close you get.
  void _theirMove() {
    _theirTurn?.cancel();
    _theirTurn = Timer(widget.theirPause, () {
      if (!mounted || _play.isOver || !theirs) return;
      final move = widget.odds.bestAt(_play.mine, _play.others, _play.turn);
      if (move == Move.bank) {
        setState(() {
          _play = _play.bank();
          _said = 'They banked, and stand on ${_play.theirs}.';
        });
      } else {
        final rolled = Rolled.from(move, _dice);
        setState(() {
          _play = _play.took(move, rolled);
          _said = _wordsFor(move, rolled, mine: false);
        });
      }
      _after();
    });
  }

  void _finished() {
    _theirTurn?.cancel();
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget
        .onOver
        ?.call(win: _play.won == Who.you, sharpness: _review.sharpness)
        .then((sharpest) {
      if (mounted && sharpest) setState(() => _sharpest = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chance = _play.isOver
        ? null
        : widget.odds.chanceAt(_play.mine, _play.others, _play.turn);

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
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onLeave,
                      icon: const Icon(Icons.arrow_back,
                          color: Palette.inkDim),
                      tooltip: 'Leave the table',
                    ),
                    const Expanded(
                      child: Text(
                        'First to ${Rules.target}',
                        style: TextStyle(color: Palette.inkDim, fontSize: 13),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: _showOdds ? 'Hide the odds' : 'Show the odds',
                      child: GestureDetector(
                        onTap: () => setState(() => _showOdds = !_showOdds),
                        child: Row(
                          children: [
                            Icon(
                              _showOdds
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 17,
                              color: _showOdds
                                  ? Palette.yours
                                  : Palette.inkDim,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'the odds',
                              style: TextStyle(
                                color:
                                    _showOdds ? Palette.yours : Palette.inkDim,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: ScoreBar(
                        name: 'You',
                        score: _play.yours,
                        mine: true,
                        toMove: _play.toMove == Who.you && !_play.isOver,
                        turn: _play.toMove == Who.you ? _play.turn : 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ScoreBar(
                        name: 'The house',
                        score: _play.theirs,
                        mine: false,
                        toMove: _play.toMove == Who.them && !_play.isOver,
                        turn: _play.toMove == Who.them ? _play.turn : 0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _Felt(play: _play, said: _said)),
              if (_play.isOver)
                ResultCard(
                  play: _play,
                  review: _review,
                  sharpest: _sharpest,
                  onAgain: widget.onAgain,
                  onLeave: widget.onLeave,
                )
              else ...[
                if (_showOdds && chance != null)
                  OddsStrip(chance: chance, waiting: theirs),
                _Hand(
                  turn: _play.turn,
                  waiting: theirs,
                  onTake: _take,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The middle of the table: what the turn is worth, and what was just thrown.
class _Felt extends StatelessWidget {
  const _Felt({required this.play, required this.said});

  final Play play;
  final String said;

  @override
  Widget build(BuildContext context) {
    final rolled = play.last;
    final mine = play.toMove == Who.you;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Palette.felt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.rail, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'this turn',
            style: const TextStyle(color: Palette.inkDim, fontSize: 13)
                .copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 4),
          Text(
            '${play.turn}',
            style: TextStyle(
              color: play.isOver
                  ? Palette.inkDim
                  : Palette.forWho(mine),
              fontSize: 68,
              fontWeight: FontWeight.w200,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 58,
            child: rolled == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final face in rolled.faces) ...[
                        Die(
                          face: face,
                          side: 54,
                          bad: face == 1,
                          doubled: rolled.doubled,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              said,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Palette.ink,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The three things anybody can do.
class _Hand extends StatelessWidget {
  const _Hand({
    required this.turn,
    required this.waiting,
    required this.onTake,
  });

  final int turn;
  final bool waiting;
  final ValueChanged<Move> onTake;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: _Button(
                label: 'Bank $turn',
                lit: true,
                dead: waiting || turn == 0,
                onTap: () => onTake(Move.bank),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Button(
                label: 'One die',
                lit: false,
                dead: waiting,
                onTap: () => onTake(Move.one),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Button(
                label: 'Two dice',
                lit: false,
                dead: waiting,
                onTap: () => onTake(Move.two),
              ),
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.lit,
    required this.dead,
    required this.onTap,
  });

  final String label;
  final bool lit;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: dead
                  ? Palette.felt
                  : lit
                      ? Palette.yours
                      : Palette.rail,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dead ? Palette.rail : Palette.yours,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dead
                      ? Palette.inkDim
                      : lit
                          ? Palette.night
                          : Palette.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
