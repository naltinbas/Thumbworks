import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/board.dart';
import '../game/game.dart';
import '../opponent.dart';
import 'board_view.dart';
import 'hud.dart';
import 'palette.dart';
import 'result_card.dart';

/// One game against the opponent.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.playing,
    required this.strength,
    required this.onLeave,
    this.opening,
  });

  /// The side the player has.
  final Side playing;

  final Strength strength;
  final VoidCallback onLeave;

  /// A game to start from. Only a test or a screenshot passes this; a player
  /// starts from the opening.
  final Game? opening;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Game _game;
  Square? _picked;
  Move? _last;
  bool _thinking = false;

  /// Bumped every time a game is started or taken back. The reply that comes
  /// home from the worker carries the number it left with, and is thrown away
  /// if it does not still match — otherwise a move thought about before an
  /// undo lands on the board after it.
  int _era = 0;

  late final AnimationController _ending;
  late final CurvedAnimation _reveal;

  @override
  void initState() {
    super.initState();
    _ending = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _reveal = CurvedAnimation(parent: _ending, curve: Curves.easeOut);
    _game = widget.opening ?? Game.fresh();
    _maybeThink();
  }

  @override
  void dispose() {
    _reveal.dispose();
    _ending.dispose();
    super.dispose();
  }

  bool get _mine => _game.board.turn == widget.playing;

  void _again() {
    setState(() {
      _era++;
      _game = Game.fresh();
      _picked = null;
      _last = null;
      _thinking = false;
    });
    _ending.value = 0;
    _maybeThink();
  }

  void _takeBack() {
    // Both moves, because a player who wants their move back after the other
    // side has replied wants the position they were looking at, not the one
    // they were not.
    if (_game.played == 0) return;
    setState(() {
      _era++;
      _game = _mine ? _game.backAPair : _game.back;
      _picked = null;
      _last = _game.moves.isEmpty ? null : _game.moves.last;
      _thinking = false;
    });
    _ending.value = 0;
    _maybeThink();
  }

  void _played(Move move) {
    setState(() {
      _game = _game.play(move);
      _picked = null;
      _last = move;
    });
    if (_game.isOver) {
      _finish();
      return;
    }
    _maybeThink();
  }

  /// If it is the opponent's move, ask it.
  Future<void> _maybeThink() async {
    if (_game.isOver || _mine || _thinking) return;
    final era = _era;
    setState(() => _thinking = true);

    final thought = await ponder(Ask(_game.board, widget.strength.depth));

    if (!mounted || era != _era) return;
    setState(() => _thinking = false);
    final move = thought.move;
    if (move == null) return;

    HapticFeedback.selectionClick();
    _played(move);
  }

  void _finish() {
    HapticFeedback.heavyImpact();
    _ending.forward(from: 0);
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  TurnBar(
                    game: _game,
                    playing: widget.playing,
                    thinking: _thinking,
                    onBack: widget.onLeave,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: BoardView(
                        board: _game.board,
                        picked: _picked,
                        last: _last,
                        dimmed: _game.isOver,
                        frozen: !_mine || _game.isOver,
                        onPick: (at) => setState(() => _picked = at),
                        onPlay: _played,
                      ),
                    ),
                  ),
                  Tools(
                    onBack: _takeBack,
                    canBack: _game.played > 0 && !_thinking,
                    onAgain: _again,
                  ),
                ],
              ),
              if (_game.isOver)
                ResultCard(
                  game: _game,
                  playing: widget.playing,
                  reveal: _reveal,
                  onAgain: _again,
                  onTitle: widget.onLeave,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
