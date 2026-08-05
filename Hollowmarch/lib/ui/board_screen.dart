import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pegs/boards.dart';
import '../pegs/guide.dart';
import '../pegs/play.dart';
import 'hollows.dart';
import 'palette.dart';
import 'result_card.dart';

/// One board: take it down to a single peg.
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

  /// Called once, the first time a board is finished, with the moves it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  static const boardKey = ValueKey('board');

  late Board _board;
  late Guide _guide;
  late Play _play;

  /// A peg picked up and waiting to be told where to go, or -1.
  var _holding = -1;

  var _pointing = <int>[];
  var _wrong = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Board get board => _board;
  Play get play => _play;
  Guide get guide => _guide;
  int get holding => _holding;
  List<int> get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  /// The hollows the peg in hand could jump to.
  List<int> get canGoTo => _holding < 0
      ? const []
      : [
          for (final jump in _play.canJump)
            if (jump.from == _holding) jump.to,
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
    _board = Boards.at(widget.number);
    _guide = Guide(_board);
    _play = Play.of(_board);
    _holding = -1;
    _pointing = const [];
    _wrong = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// A hollow, tapped. A peg in it is picked up; an empty one is jumped into
  /// if there is a peg in hand that can reach it.
  void _touched(int hollow) {
    if (_play.isDone || hollow < 0) return;

    if (_play.has(hollow)) {
      if (_play.carrying >= 0 && hollow != _play.carrying) {
        setState(() => _saying = Refusal.notThatPeg.says);
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        _holding = _holding == hollow ? -1 : hollow;
        _pointing = const [];
        _saying = null;
      });
      return;
    }

    if (_holding < 0) {
      setState(() => _saying = 'Tap a peg first, then a hollow to jump into.');
      return;
    }

    final why = _play.whyNot(_holding, hollow);
    if (why != null) {
      setState(() => _saying = why.says);
      return;
    }
    _jump(_holding, hollow);
  }

  void _jump(int from, int to) {
    final next = _play.jump(from, to);
    HapticFeedback.selectionClick();

    // The peg stays in hand while it can carry on, because carrying on is
    // one move and letting go is what ends it.
    final carryOn = next.canJump.isNotEmpty;
    setState(() {
      _play = carryOn ? next : next.letGo;
      _holding = carryOn ? next.carrying : -1;
      _pointing = const [];
      _saying = _note(carryOn ? next : next.letGo);
    });
    if (next.isDone) _finished();
  }

  /// What the board has to say for itself after a jump.
  ///
  /// Only two things are worth saying, and both are things a player cannot
  /// see: that the board can no longer be brought down to one peg, and that
  /// there is nothing left that can move at all.
  String? _note(Play play) {
    if (play.isDone) return null;
    if (play.isStuck) {
      return 'Nothing can jump. That is as far as this goes, so take some back, '
          'or start again.';
    }
    final alive = _guide.canStillFinish(play.pegs);
    if (alive == false) {
      return 'From here it can no longer come down to one peg. Take that jump '
          'back.';
    }
    return null;
  }

  void _letGo() {
    if (_play.carrying < 0 && _holding < 0) return;
    setState(() {
      _play = _play.letGo;
      _holding = -1;
      _pointing = const [];
      _saying = null;
    });
  }

  void _back() {
    if (_play.jumps.isEmpty) return;
    setState(() {
      _play = _play.back;
      _holding = _play.carrying;
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

  /// Asked. Points at a jump that keeps the board alive, worked out from
  /// where it actually stands rather than from the start.
  void _showMe() {
    if (_play.isDone) return;
    final next = _guide.next(_play);
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = const [];
        _wrong = true;
        _saying = _guide.canStillFinish(_play.pegs) == false
            ? 'There is no way down to one peg from here. Take some back.'
            : 'I cannot see a way from here.';
        return;
      }
      _pointing = [next.from, next.to];
      _wrong = false;
      _holding = next.from;
      _saying = 'That peg jumps that way.';
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
              _Ledger(board: _board, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Board(
                    play: _play,
                    holding: _play.isDone ? -1 : _holding,
                    pointing: _pointing,
                    wrong: _wrong,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  board: _board,
                  play: _play,
                  best: _best,
                  hints: _hints,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  carrying: _play.carrying >= 0,
                  canTakeBack: _play.jumps.isNotEmpty,
                  onLetGo: _letGo,
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
  Widget build(BuildContext context) {
    final par = board.par;
    final over = par != null && play.moves > par;

    return Padding(
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
                      ? 'one peg left'
                      : '${play.left} pegs, ${play.moves} '
                          '${play.moves == 1 ? 'move' : 'moves'}',
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

/// The board itself.
class _Board extends StatelessWidget {
  const _Board({
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
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play.field, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.whereIs(touch.localPosition)),
            child: CustomPaint(
              key: BoardScreenState.boardKey,
              size: size,
              painter: Hollows(
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

/// Under the board: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.carrying,
    required this.canTakeBack,
    required this.onLetGo,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final bool carrying;
  final bool canTakeBack;
  final VoidCallback onLetGo;
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
                color: Palette.wood,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.grain, width: 1.1),
              ),
              child: Text(
                saying ??
                    (carrying
                        ? 'That peg can jump again. Carrying on is still the '
                            'same move.'
                        : 'A peg jumps over its neighbour into the hollow '
                            'beyond, and the one it passed comes out.'),
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
                    label: carrying ? 'Let go' : 'Take back',
                    dead: carrying ? false : !canTakeBack,
                    onTap: carrying ? onLetGo : onBack,
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
                color: Palette.wood,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.grain : Palette.edge,
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
