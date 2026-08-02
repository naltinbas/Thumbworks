import 'package:flutter/foundation.dart';
// Flutter has a Table too, and it is a widget for laying out rows. This file
// means the one with the cards on it.
import 'package:flutter/material.dart' hide Table;
import 'package:flutter/services.dart';

import '../game/game.dart';
import '../game/solver.dart';
import '../game/table.dart';
import '../game/tapping.dart';
import 'hud.dart';
import 'palette.dart';
import 'table_painter.dart';
import 'won_card.dart';

/// Asks the solver, on a thread that is not the one drawing the screen.
///
/// A hint is a search, and a search is tens of milliseconds most of the time
/// and rather more when the player has made a mess. A frozen screen is a phone
/// that looks broken, and the table is a plain immutable object, so this is a
/// one line change rather than a rewrite.
Future<List<Move>> _askFor(Table table) => compute(_think, table);

List<Move> _think(Table table) => const Solver().solve(table).moves;

/// One deal, played.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.opening,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// A game to start from. Only a test or a screenshot passes this.
  final Game? opening;

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late Game _game;
  List<Spot> _lit = const [];
  bool _thinking = false;

  /// What is left of a line to a finished game.
  ///
  /// The whole line is kept rather than only its first move, for two reasons.
  /// Asking again is then free — the second hint and the fortieth cost
  /// nothing, where re-solving each time is a search each time. And the hints
  /// agree with each other: a fresh search can come back with a different
  /// line every time, so following one hint then the next can walk in a
  /// circle. This walks one line to the end.
  ///
  /// It is thrown away the moment the player does something else, because the
  /// line was a line from a position they are no longer in.
  List<Move> _line = const [];

  Move? get _hinted => _line.isEmpty ? null : _line.first;

  /// True once the solver has said there is no way on from here.
  bool _stuck = false;

  Game get game => _game;

  /// The longest column there is, which is what the fan is laid out from.
  int get _longestColumn {
    var longest = 1;
    for (var at = 0; at < Table.columnCount; at++) {
      final length = _game.table.column(at).length;
      if (length > longest) longest = length;
    }
    return longest;
  }

  /// Whether the solver is still being waited on, so a test can wait too.
  bool get thinking => _thinking;

  @override
  void initState() {
    super.initState();
    _game = widget.opening ?? Game.deal(widget.number);
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      setState(() {
        _game = Game.deal(widget.number);
        _line = const [];
        _lit = const [];
        _stuck = false;
      });
    }
  }

  void _tapped(Spot spot) {
    if (_game.isWon) return;

    final hinted = _hinted;
    if (hinted != null && _lit.isNotEmpty && _lit.first == spot) {
      // The player asked, and then tapped what was pointed at. That means do
      // that, not guess again — the guess only knows what looks sensible and
      // the line knows the way to a finished game.
      HapticFeedback.selectionClick();
      setState(() {
        _game = _game.play(hinted);
        _line = _line.sublist(1);
        _lit = const [];
        _stuck = false;
      });
      return;
    }

    final move = tapMove(
      _game.table,
      from: spot.where,
      at: spot.at,
      card: spot.card,
    );
    if (move == null) {
      // Nothing to do with that card. Saying so with a shake of the phone is
      // better than saying nothing, which reads as a tap that missed.
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _game = _game.play(move);
      _line = const [];
      _lit = const [];
      _stuck = false;
    });
  }

  void _undo() {
    if (!_game.canUndo) return;
    HapticFeedback.selectionClick();
    setState(() {
      _game = _game.back;
      _line = const [];
      _lit = const [];
      _stuck = false;
    });
  }

  Future<void> _hint() async {
    if (_thinking || _game.isWon) return;

    // The line from last time, if it still applies. Free, and it agrees with
    // the hint before it.
    final known = _hinted;
    if (known != null && _game.table.allows(known)) {
      setState(() => _lit = _pointAt(known));
      return;
    }

    setState(() {
      _thinking = true;
      _lit = const [];
      _line = const [];
    });

    final line = await _askFor(_game.table);
    if (!mounted) return;

    setState(() {
      _thinking = false;
      _stuck = line.isEmpty;
      _line = line;
      _lit = line.isEmpty ? const [] : _pointAt(line.first);
    });
  }

  /// What to round, given a move: the card to pick up and where it is going.
  List<Spot> _pointAt(Move move) {
    final spots = <Spot>[];
    switch (move.from) {
      case Where.cell:
        spots.add(Spot(where: Where.cell, at: move.fromAt));
      case Where.column:
        final column = _game.table.column(move.fromAt);
        spots.add(Spot(
          where: Where.column,
          at: move.fromAt,
          card: column.length - move.cards,
        ));
      case Where.home:
        break;
    }
    switch (move.to) {
      case Where.cell:
        spots.add(Spot(where: Where.cell, at: move.toAt));
      case Where.home:
        spots.add(Spot(where: Where.home, at: move.toAt));
      case Where.column:
        final column = _game.table.column(move.toAt);
        spots.add(Spot(
          where: Where.column,
          at: move.toAt,
          card: column.isEmpty ? null : column.length - 1,
        ));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.felt,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Ledger(
                    number: _game.number,
                    moves: _game.moves,
                    home: _game.table.homeCount,
                    onLeave: widget.onLeave,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final metrics = Metrics(
                          Size(box.maxWidth, box.maxHeight),
                          longest: _longestColumn,
                        );
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            final spot = metrics.under(
                              details.localPosition,
                              _game.table,
                            );
                            if (spot != null) _tapped(spot);
                          },
                          child: CustomPaint(
                            size: Size(box.maxWidth, box.maxHeight),
                            painter: TablePainter(
                              table: _game.table,
                              metrics: metrics,
                              text: Theme.of(context).textTheme.bodyMedium!,
                              lit: _lit,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Tools(
                    canUndo: _game.canUndo && !_game.isWon,
                    thinking: _thinking,
                    stuck: _stuck,
                    onUndo: _undo,
                    onHint: _hint,
                    onAgain: () => setState(() {
                      _game = _game.again;
                      _line = const [];
                      _lit = const [];
                      _stuck = false;
                    }),
                  ),
                ],
              ),
              if (_game.isWon)
                WonCard(
                  game: _game,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
