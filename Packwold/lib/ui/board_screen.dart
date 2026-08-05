import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fit/boxes.dart';
import '../fit/guide.dart';
import '../fit/pieces.dart';
import '../fit/play.dart';
import 'ground.dart';
import 'palette.dart';
import 'result_card.dart';

/// One puzzle: get every piece into the box.
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

  /// Called once, the first time a box is packed, with how many hints it
  /// took. Answers whether that beat what was written down before.
  final Future<bool> Function(int hints)? onDone;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  static const boxKey = ValueKey('box');

  late Puzzle _puzzle;
  late Guide _guide;
  late Play _play;

  /// The piece in hand, or -1. It is what Turn and Flip act on and what a tap
  /// on the box puts down.
  var _holding = -1;

  var _pointing = <int>[];
  var _wrong = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Puzzle get puzzle => _puzzle;
  Play get play => _play;
  Guide get guide => _guide;
  int get holding => _holding;
  List<int> get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

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
    // The one packing, worked out once as the puzzle opens. Every box that
    // ships has one, so this cannot come back empty.
    _guide = Guide.of(_puzzle);
    _play = Play.of(_puzzle);
    _holding = -1;
    _pointing = const [];
    _wrong = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// Picking a piece up, from the tray or off the box.
  void _pick(int piece) {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    setState(() {
      _holding = _holding == piece ? -1 : piece;
      _pointing = const [];
      _saying = null;
    });
  }

  /// A square of the box, tapped. The piece in hand goes down there; a tap on
  /// a piece already lying there picks that one up instead.
  void _touched(int row, int column) {
    if (_play.isDone) return;
    final on = _play.at(row, column);

    if (on >= 0 && on != _holding) {
      setState(() {
        _play = _play.take(on);
        _holding = on;
        _pointing = const [];
        _saying = null;
      });
      return;
    }
    if (_holding < 0) {
      setState(() => _saying = 'Take a piece from the tray first.');
      return;
    }

    final why = _play.whyNot(_holding, row, column);
    if (why != null) {
      setState(() => _saying = why.says);
      return;
    }

    final next = _play.lay(_holding, row, column);
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _holding = -1;
      _pointing = const [];
      _saying = null;
    });
    if (next.isDone) _finished();
  }

  void _turn() {
    if (_holding < 0) {
      setState(() => _saying = 'Take a piece from the tray first.');
      return;
    }
    setState(() {
      _play = _play.turn(_holding);
      _pointing = const [];
      _saying = null;
    });
  }

  void _flip() {
    if (_holding < 0) {
      setState(() => _saying = 'Take a piece from the tray first.');
      return;
    }
    setState(() {
      _play = _play.flip(_holding);
      _pointing = const [];
      _saying = null;
    });
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _holding = -1;
      _pointing = const [];
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Names a piece and points at the ground it covers — or at a piece
  /// that is in the wrong place, because that one is on ground somebody else
  /// needs and no amount of laying pieces elsewhere will help.
  void _showMe() {
    if (_play.isDone) return;
    final step = _guide.next(_play);
    setState(() {
      _hints++;
      if (step == null) {
        _pointing = const [];
        _saying = 'Everything is where it should be.';
        return;
      }
      _pointing = step.cells;
      _wrong = step.wrong;
      _holding = step.wrong ? -1 : step.piece;
      if (!step.wrong) _play = _play.take(step.piece);
      _saying = step.wrong
          ? 'The ${step.letter} is not where it belongs. Take it off.'
          : 'The ${step.letter} covers those five squares. '
              '${_guide.left(_play)} pieces to go.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_hints).then((best) {
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
              _Ledger(puzzle: _puzzle, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Box(
                    play: _play,
                    holding: _play.isDone ? -1 : _holding,
                    pointing: _pointing,
                    wrong: _wrong,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (!_play.isDone)
                _Tray(play: _play, holding: _holding, onPick: _pick),
              if (_play.isDone)
                ResultCard(
                  puzzle: _puzzle,
                  hints: _hints,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onTurn: _turn,
                  onFlip: _flip,
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

/// The line above the box: which puzzle, and how it is going.
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
                        ? 'packed'
                        : '${play.laid} of ${play.pieces} laid, '
                            '${play.empty} squares bare',
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
              '${play.filled} / ${play.box.cells}',
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

/// The box itself.
class _Box extends StatelessWidget {
  const _Box({
    required this.play,
    required this.holding,
    required this.pointing,
    required this.wrong,
    required this.onTouch,
  });

  final Play play;
  final int holding;
  final List<int> pointing;
  final bool wrong;
  final void Function(int row, int column) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play.box, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final where = metrics.whereIs(touch.localPosition);
              if (where != null) onTouch(where.$1, where.$2);
            },
            child: CustomPaint(
              key: BoardScreenState.boxKey,
              size: size,
              painter: Ground(
                play: play,
                holding: holding,
                pointing: pointing,
                wrong: wrong,
              ),
            ),
          );
        },
      );
}

/// The pieces still to go in, and the one in hand.
class _Tray extends StatelessWidget {
  const _Tray({
    required this.play,
    required this.holding,
    required this.onPick,
  });

  final Play play;
  final int holding;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final waiting = [
      for (var piece = 0; piece < play.pieces; piece++)
        if (!play.isLaid(piece)) piece,
    ];

    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        children: [
          for (final piece in waiting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Waiting(
                play: play,
                piece: piece,
                held: piece == holding,
                onPick: () => onPick(piece),
              ),
            ),
          if (waiting.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'The tray is empty.',
                  style: TextStyle(color: Palette.inkDim, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({
    required this.play,
    required this.piece,
    required this.held,
    required this.onPick,
  });

  final Play play;
  final int piece;
  final bool held;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final shape = play.shapeOf(piece);

    return Semantics(
      button: true,
      label: 'the ${play.letters[piece]} piece${held ? ', in hand' : ''}',
      child: GestureDetector(
        onTap: onPick,
        child: ExcludeSemantics(
          child: Container(
            width: 72,
            decoration: BoxDecoration(
              color: held ? Palette.furrow : Palette.chalk,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: held ? Palette.ink : Palette.furrow,
                width: held ? 1.6 : 1.1,
              ),
            ),
            padding: const EdgeInsets.all(7),
            child: CustomPaint(
              painter: Held(
                shape: shape,
                piece: Piece.numberOf(play.letters[piece]),
                faded: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Under the tray: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onTurn,
    required this.onFlip,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final VoidCallback onTurn;
  final VoidCallback onFlip;
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
                color: Palette.chalk,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.furrow, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Take a piece, turn it about, and tap where its first '
                        'square goes.',
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
                Expanded(child: _Button(label: 'Turn', onTap: onTurn)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Flip', onTap: onFlip)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 8),
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
                color: Palette.chalk,
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
