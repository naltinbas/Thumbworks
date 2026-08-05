import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../board/board.dart';
import '../board/pieces.dart';
import '../board/play.dart';
import '../board/puzzles.dart';
import 'man.dart';
import 'palette.dart';
import 'result_card.dart';

/// One puzzle: take every piece but one, and every move a capture.
class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once the first time a puzzle is finished. Answers whether it was
  /// finished without a capture taken back.
  final Future<bool> Function({required bool clean})? onDone;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  late Puzzle _puzzle;
  late Play _play;

  /// The square of the piece about to take, or -1.
  var _picked = -1;

  String? _saying;

  /// Whether anything has been taken back or started over. A puzzle with one
  /// way through is only really solved if it was solved first time.
  var _helped = false;
  var _clean = false;
  var _told = false;

  Puzzle get puzzle => _puzzle;
  Play get play => _play;
  int get picked => _picked;
  String? get saying => _saying;
  bool get helped => _helped;

  /// The squares the picked piece could take on.
  List<int> get targets => _picked < 0
      ? const []
      : [
          for (final move in _play.board.moves)
            if (move.from == _picked) move.to,
        ];

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _puzzle = Puzzles.at(widget.number);
    _play = Play.of(_puzzle);
    _picked = -1;
    _saying = null;
    _helped = false;
    _clean = false;
    _told = false;
  }

  void _touched(int square) {
    if (_play.isOver) return;

    // A square with one of the picked piece's captures on it takes it. Any
    // other piece becomes the picked one, and anything else lets go.
    if (_picked >= 0 && targets.contains(square)) {
      _take(Move(_picked, square));
      return;
    }
    setState(() {
      _picked = _play.board.holds(square) && square != _picked ? square : -1;
      _saying = _picked < 0
          ? null
          : _play.board.at(_picked)!.says;
    });
  }

  void _take(Move move) {
    HapticFeedback.selectionClick();
    final next = _play.after(move);
    setState(() {
      _play = next;
      _picked = -1;
      _saying = next.isDone
          ? null
          : next.isStuck
              ? 'Nothing can take anything. Take one back.'
              : next.canStillBeDone
                  ? null
                  : 'That leaves it with no way through. Take it back.';
    });
    if (next.isOver) _finished();
  }

  void _back() {
    if (_play.taken == 0) return;
    setState(() {
      _play = _play.back;
      _picked = -1;
      _saying = null;
      _helped = true;
    });
  }

  void _again() {
    setState(() {
      final helped = _play.taken > 0;
      _play = _play.again;
      _picked = -1;
      _saying = null;
      if (helped) _helped = true;
      _told = false;
      _clean = false;
    });
  }

  /// Asked. Points at the capture that is on the one way through from here —
  /// which is the honest answer, because a hint read off the way through from
  /// the start is advice about a board nobody is looking at.
  void _showMe() {
    if (_play.isOver) return;
    final next = _play.nextTake;
    setState(() {
      _helped = true;
      if (next == null) {
        _picked = -1;
        _saying = 'There is no way through from here. Take one back.';
        return;
      }
      _picked = next.from;
      _saying = 'The ${_play.board.at(next.from)!.name} takes.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told || !_play.isDone) return;
    _told = true;
    widget.onDone?.call(clean: !_helped).then((clean) {
      if (mounted && clean) setState(() => _clean = true);
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
            children: [
              _Ledger(
                puzzle: _puzzle,
                play: _play,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Squares(
                      board: _play.board,
                      picked: _picked,
                      targets: targets,
                      onTouch: _touched,
                    ),
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  puzzle: _puzzle,
                  play: _play,
                  clean: _clean && !_helped,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canTakeBack: _play.taken > 0,
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

/// The line above the board: which puzzle, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.puzzle,
    required this.play,
    required this.onLeave,
  });

  final Puzzle puzzle;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
        child: Row(
          children: [
            IconButton(
              onPressed: onLeave,
              icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
              tooltip: 'Back to the puzzles',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    puzzle.name,
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
                        ? 'one left'
                        : '${play.board.count} pieces, and every move a take',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${play.taken} / ${puzzle.takes}',
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

/// The board itself.
class _Squares extends StatelessWidget {
  const _Squares({
    required this.board,
    required this.picked,
    required this.targets,
    required this.onTouch,
  });

  final Board board;
  final int picked;
  final List<int> targets;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final side = (box.maxWidth / board.side).clamp(40.0, 88.0);

        return SizedBox(
          width: side * board.side,
          height: side * board.side,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < board.side; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var column = 0; column < board.side; column++)
                      _One(
                        square: row * board.side + column,
                        side: side,
                        board: board,
                        picked: picked,
                        target: targets
                            .contains(row * board.side + column),
                        onTouch: onTouch,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _One extends StatelessWidget {
  const _One({
    required this.square,
    required this.side,
    required this.board,
    required this.picked,
    required this.target,
    required this.onTouch,
  });

  final int square;
  final double side;
  final Board board;
  final int picked;
  final bool target;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    final piece = board.at(square);
    final pale = (board.rowOf(square) + board.columnOf(square)).isEven;

    return Semantics(
      button: true,
      label: 'square ${square + 1}'
          '${piece == null ? ', empty' : ', ${piece.name}'}'
          '${target ? ', can be taken' : ''}',
      child: GestureDetector(
        onTap: () => onTouch(square),
        child: ExcludeSemantics(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: pale ? Palette.light : Palette.dark,
              border: target
                  ? Border.all(color: Palette.target, width: 3)
                  : null,
            ),
            alignment: Alignment.center,
            child: piece == null
                ? null
                : Man(
                    piece: piece,
                    side: side * 0.62,
                    picked: square == picked,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Under the board: what the game has to say, and what else can be done.
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
                color: Palette.board,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.light, width: 1.1),
              ),
              child: Text(
                saying ?? 'Tap a piece, then something it can take.',
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
                  child: _Button(
                    label: 'Show me',
                    dead: false,
                    onTap: onShowMe,
                  ),
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
                color: Palette.board,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.light : Palette.picked,
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
