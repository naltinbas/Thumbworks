import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../thread/boards.dart';
import '../thread/guide.dart';
import '../thread/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'weave.dart';

/// One board: join every thread and leave no cell empty.
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

  /// Called once, the first time a board is filled, with how many hints it
  /// took. Answers whether that beat what was written down before.
  final Future<bool> Function(int hints)? onDone;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  static const boardKey = ValueKey('board');

  late Board _board;
  late Guide _guide;
  late Play _play;

  /// The thread a finger is drawing, or -1. It stays put after the finger
  /// lifts, so a board can be filled by tapping one cell at a time as well as
  /// by dragging.
  var _thread = -1;

  var _pointing = -1;
  var _rubbing = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Board get board => _board;
  Play get play => _play;
  Guide get guide => _guide;
  int get thread => _thread;
  int get pointing => _pointing;
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
    _board = Boards.at(widget.number);
    // The one way through, worked out once as the board opens. Every board
    // that ships has one, so this cannot come back empty.
    _guide = Guide.of(_board);
    _play = Play.of(_board);
    _thread = -1;
    _pointing = -1;
    _rubbing = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// A finger landing on a cell.
  ///
  /// What is under the finger decides, and in this order: an end takes hold
  /// of its thread and starts it again from there, wool takes hold of the
  /// thread it belongs to and rubs it back to the finger, and bare peat
  /// carries on whatever is already in hand. Putting the thread in hand first
  /// would mean a line could never be picked up while it lay next to another
  /// one, which on a full board is most of the time.
  void _touched(int at) {
    if (_play.isDone || at < 0) return;

    final end = _play.field.endAt(at);

    if (end >= 0) {
      // Except the far end of the thread in hand, next to where it has got
      // to: that is not taking hold of anything, that is joining it up.
      if (_thread >= 0 && _play.canGoTo(_thread, at)) {
        _moved(at);
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        _thread = end;
        _play = _play.startFrom(end, at);
        _pointing = -1;
        _saying = null;
      });
      return;
    }

    final owner = _play.ownerOf(at);
    if (owner >= 0 && _play.isOn(owner, at)) {
      setState(() {
        _thread = owner;
        _play = _play.backTo(owner, at);
        _pointing = -1;
        _saying = null;
      });
      return;
    }
    _moved(at);
  }

  /// A finger arriving on a cell with a thread already in hand.
  void _moved(int at) {
    if (_play.isDone || _thread < 0 || at < 0) return;
    if (at == _play.headOf(_thread)) return;

    final next = _play.draw(_thread, at);
    if (identical(next, _play)) return;

    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the board has to say for itself, which is nothing at all unless
  /// every thread is joined and cells are still empty. That is the one thing
  /// a player can look at a full-looking board and miss.
  String? _note(Play play) {
    if (play.isDone) return null;
    if (play.joined < play.field.threads) return null;
    if (play.empty == 0) return null;
    return 'Every thread is joined, but ${play.empty} '
        '${play.empty == 1 ? 'cell is' : 'cells are'} still empty. One of '
        'them has to go a longer way round.';
  }

  void _rubOut() {
    if (_thread < 0) return;
    setState(() {
      _play = _play.clear(_thread);
      _pointing = -1;
      _saying = null;
    });
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _thread = -1;
      _pointing = -1;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at one cell of the one way through — or at a cell that is
  /// not on it, because a thread in the wrong place is in somebody else's way
  /// and no amount of drawing elsewhere will help.
  void _showMe() {
    if (_play.isDone) return;
    final step = _guide.next(_play);
    setState(() {
      _hints++;
      if (step == null) {
        _pointing = -1;
        _saying = 'Everything is where it should be.';
        return;
      }
      _pointing = step.at;
      _rubbing = step.wrong;
      _thread = step.thread;
      final letter = String.fromCharCode(97 + step.thread);
      _saying = step.wrong
          ? 'The $letter thread does not go through there. Rub it back that '
              'far.'
          : 'The $letter thread goes through there next. '
              '${_guide.left(_play)} cells to go.';
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
              _Ledger(board: _board, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Board(
                    play: _play,
                    // Nothing is in hand once the board is filled.
                    holding: _play.isDone ? -1 : _thread,
                    pointing: _pointing,
                    rubbing: _rubbing,
                    onTouch: _touched,
                    onMove: _moved,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  board: _board,
                  hints: _hints,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canRubOut: _thread >= 0 && _play.pathOf(_thread).length > 1,
                  onRubOut: _rubOut,
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

/// The line above the board: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.board,
    required this.play,
    required this.onLeave,
  });

  final Board board;
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
              tooltip: 'Back to the boards',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
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
                        ? 'filled'
                        : '${play.joined} of ${play.field.threads} joined, '
                            '${play.empty} empty',
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
              '${play.filled} / ${play.field.cells}',
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

/// The board, and the finger on it.
class _Board extends StatelessWidget {
  const _Board({
    required this.play,
    required this.holding,
    required this.pointing,
    required this.rubbing,
    required this.onTouch,
    required this.onMove,
  });

  final Play play;
  final int holding;
  final int pointing;
  final bool rubbing;
  final ValueChanged<int> onTouch;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          final metrics = Metrics(play.field, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (touch) => onTouch(metrics.cellAt(touch.localPosition)),
            onPanUpdate: (touch) => onMove(metrics.cellAt(touch.localPosition)),
            child: CustomPaint(
              key: BoardScreenState.boardKey,
              size: size,
              painter: Weave(
                play: play,
                holding: holding,
                pointing: pointing,
                rubbing: rubbing,
              ),
            ),
          );
        },
      );
}

/// Under the board: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canRubOut,
    required this.onRubOut,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final bool canRubOut;
  final VoidCallback onRubOut;
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
                color: Palette.peat,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.furrow, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Drag from one end to the other. Every cell has to end up '
                        'under a thread.',
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
                    label: 'Rub out',
                    dead: !canRubOut,
                    onTap: onRubOut,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Again', dead: false, onTap: onAgain),
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
                color: Palette.peat,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.furrow : Palette.edge,
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
