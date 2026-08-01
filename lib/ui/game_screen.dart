import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/grid.dart';
import '../game/levels.dart';
import '../game/progress.dart';
import 'board_view.dart';
import 'palette.dart';
import 'solved_banner.dart';

/// One level being played.
///
/// The screen owns the board and hands a new one down on every turn, which is
/// the only place a move is counted. Moving on to the next level swaps the
/// board in place rather than pushing another screen, so the back button
/// always means the menu.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level, required this.progress});

  final int level;
  final Progress progress;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Level _level;
  late Board _board;
  int _moves = 0;
  bool _solved = false;
  int? _bestBefore;

  /// Built here rather than in the field, because a level the player leaves
  /// without solving never touches it, and a lazy field would then be created
  /// for the first time on the way out.
  late final AnimationController _reward;

  /// How far the words around the board are allowed to grow.
  ///
  /// This screen cannot scroll, so every logical pixel the header and the
  /// reward take is one the board does not get. Left alone, a device set to
  /// its largest text runs the two of them past the bottom of a short phone
  /// and squeezes the grid down to nothing on the rest. The board is the
  /// content here and the words are labels on it, so the labels give first.
  static const _maxTextScale = 1.35;

  /// The most of the screen the reward may take before it has to fit itself
  /// into the space rather than ask for more. Nothing under the board is
  /// worth more room than the board.
  static const _rewardShare = 0.7;

  @override
  void initState() {
    super.initState();
    _reward = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _load(widget.level);
  }

  @override
  void dispose() {
    _reward.dispose();
    super.dispose();
  }

  void _load(int number) {
    _level = Level.forNumber(number);
    _board = _level.board();
    _moves = 0;
    _solved = false;
    // Read before the level is won, so the banner can say the player beat it.
    _bestBefore = widget.progress.bestMoves(number);
  }

  /// Puts a different level up, once the reward has got out of the way.
  Future<void> _swapTo(int number) async {
    if (_reward.value > 0) await _reward.reverse();
    if (!mounted) return;
    setState(() => _load(number));
  }

  void _turn(int row, int col) {
    final next = _board.turn(row, col);
    final moves = _moves + 1;
    final solved = next.isSolved;

    setState(() {
      _board = next;
      _moves = moves;
      _solved = solved;
    });

    HapticFeedback.selectionClick();
    if (!solved) return;

    HapticFeedback.mediumImpact();
    _reward.forward();
    // Saved on the win rather than on the way out, so a player who closes the
    // app while looking at the banner still keeps the level. Not awaited,
    // because the banner should not wait on a disk write, but a failure is
    // reported rather than dropped: the next win writes the level again, and
    // an unhandled error here would take the whole zone down over a save.
    unawaited(
      widget.progress.recordSolved(_level.number, moves).catchError(
            (Object error, StackTrace stack) => FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stack,
                library: 'wirewend',
                context:
                    ErrorDescription('saving the level the player just solved'),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: _maxTextScale),
      ),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backdrop,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, space) => Column(
            // Stretched so the reward reaches both edges of the screen when
            // it takes the bottom over, rather than sitting in a box of its
            // own.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                level: _level.number,
                lit: _board.litLampCount,
                lamps: _board.lampCount,
                moves: _moves,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Stack(
                  children: [
                    _SolvedGlow(showing: _solved),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: BoardView(
                        board: _board,
                        // A solved board is a picture, not a puzzle, so it
                        // stops taking taps the moment the last lamp lights.
                        onTapCell: _solved ? null : _turn,
                      ),
                    ),
                  ],
                ),
              ),
              // The reward takes the bottom of the screen over from the
              // footer rather than covering the board with it. Growing the
              // space it needs is what pushes the lit board up out of the way
              // instead of hiding half of it. The ceiling is what stops a
              // short screen and large text between them pushing the whole
              // column past the bottom: past it the banner has to fit.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: space.maxHeight * _rewardShare,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _solved
                      ? SolvedBanner(
                          level: _level.number,
                          moves: _moves,
                          bestBefore: _bestBefore,
                          rise: _reward,
                          onNext: () => _swapTo(_level.number + 1),
                          onReplay: () => _swapTo(_level.number),
                        )
                      : _Footer(
                          showHint: _level.number == 1 && _moves == 0,
                          onRestart: () => _swapTo(_level.number),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Which level this is, how far through it the player is, and what it has
/// cost them so far.
class _Header extends StatelessWidget {
  const _Header({
    required this.level,
    required this.lit,
    required this.lamps,
    required this.moves,
    required this.onBack,
  });

  final int level;
  final int lit;
  final int lamps;
  final int moves;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: Palette.inkDim,
            tooltip: 'Back to the menu',
          ),
          Expanded(
            // Both lines are labels on the board rather than prose, so they
            // are held to one line each: a header that wraps grows down into
            // the board, which is the one thing on the screen worth the room.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $level',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$lit of $lamps lamps lit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: lit == lamps ? Palette.accent : Palette.inkDim,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          MoveCounter(moves: moves),
        ],
      ),
    );
  }
}

/// The move count, in a box of its own so it reads as a score rather than as
/// another line of text.
class MoveCounter extends StatelessWidget {
  const MoveCounter({super.key, required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.panelEdge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$moves',
            maxLines: 1,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          Text(
            moves == 1 ? 'move' : 'moves',
            maxLines: 1,
            style: const TextStyle(
              color: Palette.inkDim,
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one thing to do that is not a move.
class _Footer extends StatelessWidget {
  const _Footer({required this.showHint, required this.onRestart});

  /// Shown on the first level until the player makes a move, which is the
  /// only moment anyone needs telling how the game works.
  final bool showHint;

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHint)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Tap a tile to turn it a quarter.',
                style: TextStyle(color: Palette.inkDim, fontSize: 14),
              ),
            ),
          TextButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded, size: 19),
            label: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

/// Warmth behind the board once it is solved, so the win reaches past the
/// panel and the screen itself changes rather than one widget in it.
class _SolvedGlow extends StatelessWidget {
  const _SolvedGlow({required this.showing});

  final bool showing;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: showing ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.8,
              colors: [
                Palette.accent.withValues(alpha: 0.16),
                Palette.accent.withValues(alpha: 0),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
