import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lock/boards.dart';
import '../lock/lock.dart';
import '../lock/marks.dart';
import '../lock/play.dart';
import '../lock/solver.dart';
import 'palette.dart';
import 'peg.dart';
import 'result_card.dart';

/// One lock: guess the code before the guesses run out.
class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onAgain,
    this.onOpened,
    this.marks,
    this.secret,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onAgain;

  /// Called once when a lock is opened, with the guesses it took. Answers
  /// whether that was the fewest yet.
  final Future<bool> Function(int guesses)? onOpened;

  /// A table somebody has already worked out, and a code to hide. A test or a
  /// screenshot passes these; the game works them out for itself.
  final Marks? marks;
  final int? secret;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  late Board _board;
  Marks? _marks;
  Play? _play;

  /// The pegs put in the row that has not been tried yet.
  final _picking = <int>[];

  String? _saying;
  var _best = false;
  var _told = false;

  Board get board => _board;
  Play? get play => _play;
  List<int> get picking => List.unmodifiable(_picking);
  String? get saying => _saying;
  bool get isWorking => _marks == null;

  Lock get lock => _board.lock;

  @override
  void initState() {
    super.initState();
    _set();
    _cutTheKey();
  }

  @override
  void didUpdateWidget(BoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      setState(_set);
      _cutTheKey();
    }
  }

  void _set() {
    _board = Boards.at(widget.number);
    _marks = widget.marks;
    _play = _marks == null
        ? null
        : Play.of(_board, _marks!, secret: widget.secret);
    _picking.clear();
    _saying = null;
    _best = false;
    _told = false;
  }

  /// A few thousand codes marked against every other is a few million pairs.
  /// It takes a moment, and the phone should not be holding still through it,
  /// so it happens on an isolate of its own.
  Future<void> _cutTheKey() async {
    if (_marks != null) return;
    final shape = (lock.pegs, lock.colours);
    final table = Marks.from(lock, await compute(tableFor, shape));
    if (!mounted) return;
    setState(() {
      _marks = table;
      _play = Play.of(_board, table, secret: widget.secret);
    });
  }

  void _put(int colour) {
    final play = _play;
    if (play == null || play.isOver) return;
    if (_picking.length >= lock.pegs) return;
    HapticFeedback.selectionClick();
    setState(() {
      _picking.add(colour);
      _saying = null;
    });
  }

  void _takeBack() {
    if (_picking.isEmpty) return;
    setState(() {
      _picking.removeLast();
      _saying = null;
    });
  }

  void _tryIt() {
    final play = _play;
    if (play == null || play.isOver) return;
    if (_picking.length != lock.pegs) return;

    HapticFeedback.mediumImpact();
    final next = play.tried(lock.codeOf(_picking));
    setState(() {
      _play = next;
      _picking.clear();
      _saying = null;
    });
    if (next.isOver) _finished(next);
  }

  void _finished(Play play) {
    if (_told || !play.isOpen) return;
    _told = true;
    widget.onOpened?.call(play.tries.length).then((best) {
      if (mounted && best) setState(() => _best = true);
    });
  }

  /// Asked. Works out the guess that leaves the least behind whatever the
  /// answer turns out to be, puts it in the row, and says what it is worth.
  void _showMe() {
    final play = _play;
    final marks = _marks;
    if (play == null || marks == null || play.isOver) return;

    final worst = Solver(marks).best(play.could);
    setState(() {
      _picking
        ..clear()
        ..addAll(lock.pegsOf(worst.guess));
      _saying = play.could.length == 1
          ? 'Only one code still fits, so this is it.'
          : 'Of every code you could name, this one leaves the fewest '
                'standing: ${worst.most} at worst, out of ${play.could.length}.'
                '${worst.couldBe ? ' And it might be the code itself.' : ''}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final play = _play;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: play == null
              ? const _Cutting()
              : Column(
                  children: [
                    _Ledger(board: _board, play: play, onLeave: widget.onLeave),
                    Expanded(
                      child: _Rows(play: play, picking: _picking),
                    ),
                    if (play.isOver)
                      ResultCard(
                        board: _board,
                        play: play,
                        best: _best,
                        onAgain: widget.onAgain,
                        onLeave: widget.onLeave,
                      )
                    else
                      _Bench(
                        lock: lock,
                        picking: _picking,
                        left: play.could.length,
                        saying: _saying,
                        onPut: _put,
                        onTakeBack: _takeBack,
                        onTry: _tryIt,
                        onShowMe: _showMe,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// While the table of marks is being worked out.
class _Cutting extends StatelessWidget {
  const _Cutting();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Palette.brass,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Cutting the key',
          style: TextStyle(
            color: Palette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Marking every code against every other, once,\nso nothing '
          'after this has to wait.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.inkDim, fontSize: 13, height: 1.4),
        ),
      ],
    ),
  );
}

/// The line above the rows: which lock, and how many guesses are left.
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
          tooltip: 'Back to the locks',
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
                board.about.toLowerCase(),
                style: const TextStyle(color: Palette.inkDim, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '${play.left} left',
          style: TextStyle(
            color: play.left <= 1 ? Palette.bad : Palette.ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

/// Every row of the lock: the ones tried, the one being filled, and the ones
/// still to come.
class _Rows extends StatelessWidget {
  const _Rows({required this.play, required this.picking});

  final Play play;
  final List<int> picking;

  @override
  Widget build(BuildContext context) {
    final lock = play.lock;
    final rows = play.board.inside;

    return LayoutBuilder(
      builder: (context, box) {
        // The pegs are as big as the room allows and no bigger, so a lock of
        // five pegs and one of four both fill the same board rather than one
        // of them rattling around in it.
        //
        // What the room is has to be counted out rather than guessed at:
        // everything else on the row is a fixed width, and a peg that is one
        // pixel too wide overflows every row in the lock at once.
        final marking = (lock.pegs / 2).ceil().clamp(2, 99) * 15.0;
        const listPadding = 32.0;
        const rowPadding = 24.0;
        const howManyLeft = 34.0;
        const gap = 10.0;
        final room =
            box.maxWidth -
            listPadding -
            rowPadding -
            howManyLeft -
            gap -
            marking;
        final side = (room / lock.pegs - 6).clamp(20.0, 46.0);

        // Centred rather than piled at the top: a lock is five or six rows
        // and the screen is twenty, and a board floating in the middle of the
        // phone looks like a board rather than like the top of a list.
        return Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              for (var row = 0; row < rows; row++)
                _row(context, row, lock, side),
            ],
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, int row, Lock lock, double side) {
    final tried = row < play.tries.length ? play.tries[row] : null;
    final filling = row == play.tries.length && !play.isOver;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: filling ? Palette.bench : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filling ? Palette.brass : Palette.groove,
          width: filling ? 1.4 : 1.1,
        ),
      ),
      child: Row(
        children: [
          // Shrunk to fit rather than sized to a guess at how much
          // room is left. The arithmetic above gets a row of five
          // pegs within a few pixels of right, and a few pixels is
          // the difference between a board and a row of overflow
          // stripes on every line of it.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  for (var peg = 0; peg < lock.pegs; peg++) ...[
                    Peg(
                      side: side,
                      colour: tried != null
                          ? lock.pegsOf(tried.guess)[peg]
                          : (filling && peg < picking.length
                                ? picking[peg]
                                : 0),
                      empty:
                          tried == null && !(filling && peg < picking.length),
                      lit: filling && peg == picking.length,
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (tried != null) ...[
            Text(
              '${tried.left}',
              style: const TextStyle(
                color: Palette.inkDim,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            Marking(mark: tried.mark, lock: lock),
          ],
        ],
      ),
    );
  }
}

/// The bench: the colours to choose from, and what to do with them.
class _Bench extends StatelessWidget {
  const _Bench({
    required this.lock,
    required this.picking,
    required this.left,
    required this.saying,
    required this.onPut,
    required this.onTakeBack,
    required this.onTry,
    required this.onShowMe,
  });

  final Lock lock;
  final List<int> picking;

  /// How many codes still fit everything that has come back.
  final int left;

  final String? saying;
  final ValueChanged<int> onPut;
  final VoidCallback onTakeBack;
  final VoidCallback onTry;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) {
    final full = picking.length == lock.pegs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saying != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.groove, width: 1.1),
              ),
              child: Text(
                saying!,
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: Text(
              left == 1 ? 'one code still fits' : '$left codes still fit',
              style: const TextStyle(color: Palette.inkDim, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var colour = 0; colour < lock.colours; colour++)
                Semantics(
                  button: true,
                  label: 'colour ${colour + 1}',
                  child: GestureDetector(
                    onTap: () => onPut(colour),
                    child: Peg(colour: colour, side: 40),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: 'Take back',
                  dead: picking.isEmpty,
                  onTap: onTakeBack,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Button(
                  label: 'Try it',
                  lit: true,
                  dead: !full,
                  onTap: onTry,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.dead,
    required this.onTap,
    this.lit = false,
  });

  final String label;
  final bool dead;
  final bool lit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: dead ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: dead
              ? Palette.bench
              : lit
              ? Palette.brass
              : Palette.groove,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: dead ? Palette.groove : Palette.brass,
            width: 1.1,
          ),
        ),
        child: Center(
          child: Text(
            label,
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
