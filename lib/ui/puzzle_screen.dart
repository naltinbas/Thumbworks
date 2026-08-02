import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/book.dart';
import '../game/grid.dart';
import '../game/line.dart';
import '../game/maker.dart';
import '../progress.dart';
import 'away_cover.dart';
import 'board_view.dart';
import 'done_card.dart';
import 'hud.dart';
import 'palette.dart';

/// One puzzle, from opening it to getting the picture out.
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({
    super.key,
    required this.number,
    required this.progress,
    required this.onNumber,
    required this.onBook,
  });

  final int number;
  final Progress progress;

  /// Move to another puzzle, which the book above this decides how to do.
  final ValueChanged<int> onNumber;

  final VoidCallback onBook;

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late Puzzle _puzzle;
  late Grid _grid;

  /// One entry per stroke, so undo takes back a stroke rather than a square.
  /// A stroke is what the player thinks they did.
  final _undo = <Grid>[];

  Mode _mode = Mode.fill;
  bool _done = false;
  bool _beat = false;
  Duration _took = Duration.zero;

  /// Seconds elapsed, as something the clock in the bar can be rebuilt from
  /// without rebuilding the board under it.
  late final AnimationController _clock;
  late final AnimationController _ending;
  late final CurvedAnimation _reveal;

  /// Stopped while the app is away, so a puzzle put down at a bus stop is not
  /// a puzzle that took forty minutes.
  bool _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(hours: 2),
      upperBound: const Duration(hours: 2).inSeconds.toDouble(),
    );
    _ending = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _reveal = CurvedAnimation(parent: _ending, curve: Curves.easeOut);
    _open(widget.number);
  }

  @override
  void didUpdateWidget(PuzzleScreen old) {
    super.didUpdateWidget(old);
    if (old.number != widget.number) _open(widget.number);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_done) return;
    // Coming back does not start the clock. The player says when, by tapping
    // the cover, so the seconds between the app being on screen and their
    // attention being on it are not charged to them.
    if (state == AppLifecycleState.resumed) return;
    if (_away) return;
    _clock.stop();
    setState(() => _away = true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reveal.dispose();
    _clock.dispose();
    _ending.dispose();
    super.dispose();
  }

  void _open(int number) {
    // Made before the frame it goes on: finding a picture that is both
    // solvable and hard enough means drawing a few hundred and solving each,
    // which is tens of milliseconds and not something to do mid-animation.
    final puzzle = Book.at(number);
    setState(() {
      _puzzle = puzzle;
      _grid = Grid(width: puzzle.width, height: puzzle.height);
      _undo.clear();
      _done = false;
      _beat = false;
      _mode = Mode.fill;
    });
    _ending.value = 0;
    _clock.value = 0;
    _clock.forward();
  }

  void _resume() {
    if (!_away) return;
    setState(() => _away = false);
    if (!_done) _clock.forward();
  }

  void _stroke() => _undo.add(_grid);

  void _mark(int row, int col, Square to) {
    setState(() => _grid = _grid.mark(row, col, to));
    if (_grid.matches(_puzzle.picture)) _finish();
  }

  void _takeBack() {
    if (_undo.isEmpty) return;
    setState(() => _grid = _undo.removeLast());
    HapticFeedback.selectionClick();
  }

  Future<void> _finish() async {
    _clock.stop();
    final took = Duration(seconds: _clock.value.round());
    final before = widget.progress.took(widget.number);

    HapticFeedback.heavyImpact();
    setState(() {
      _done = true;
      _took = took;
      _beat = before != null && took < before;
    });
    _ending.forward(from: 0);

    await widget.progress.record(widget.number, took);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final best = widget.progress.took(widget.number) ?? _took;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBook();
      },
      child: Scaffold(
        backgroundColor: Palette.paper,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  PuzzleBar(
                    number: widget.number,
                    elapsed: _clock,
                    onBack: widget.onBook,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: IgnorePointer(
                        ignoring: _done || _away,
                        child: BoardView(
                          grid: _grid,
                          clues: _puzzle.clues,
                          mode: _mode,
                          onStroke: _stroke,
                          onMark: _mark,
                          finished: _done,
                        ),
                      ),
                    ),
                  ),
                  Tools(
                    mode: _mode,
                    onMode: (mode) => setState(() => _mode = mode),
                    onUndo: _takeBack,
                    canUndo: _undo.isNotEmpty && !_done,
                  ),
                ],
              ),
              if (_away)
                AwayCover(
                  elapsed: Duration(seconds: _clock.value.round()),
                  onResume: _resume,
                ),
              if (_done)
                DoneCard(
                  number: widget.number,
                  puzzle: _puzzle,
                  took: _took,
                  best: best,
                  beat: _beat,
                  reveal: _reveal,
                  onNext: () => widget.onNumber(widget.number + 1),
                  onBook: widget.onBook,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
