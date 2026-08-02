import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../best_score.dart';
import '../game/board.dart';
import '../game/lexicon.dart';
import '../game/round.dart';
import 'found_list.dart';
import 'hud.dart';
import 'palette.dart';
import 'play_area.dart';
import 'summary_card.dart';
import 'title_screen.dart';

/// What the player is looking at.
enum Phase { title, playing, over }

/// The game around a board: a title, a round against a clock, and what the
/// round came to.
///
/// The round underneath stays on screen when it ends. A player wants to see
/// the letters they were staring at while they read the list of what was in
/// them, and a board that vanished the moment the clock stopped would take
/// the answer with it.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.lexicon,
    required this.best,
    this.seeds,
    this.length = Round.standardLength,
  });

  final Lexicon lexicon;
  final BestScore best;

  /// Where a new round's seed comes from. The game picks a fresh one each go;
  /// a test or a screenshot passes one in so it plays a board it has chosen.
  final int Function()? seeds;

  /// How long a round lasts. A test shortens it so the clock running out is
  /// something it can wait for.
  final Duration length;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  /// The round's clock. Its value is how much of the round has gone, which is
  /// what both the seconds and the line under them are drawn from.
  late final AnimationController _clock;

  /// The end of the round arriving over the board.
  late final AnimationController _ending;
  late final CurvedAnimation _reveal;

  Phase _phase = Phase.title;
  Round? _round;
  bool _beatBest = false;

  /// Whether the clock is what ended the last round, rather than the player.
  bool _ranOut = true;

  /// Counts the rounds played, and nothing else. It is the key on the play
  /// area, so a new round is a new state: no word left over in the line above
  /// the board from the round before, even when the board is the same one.
  int _go = 0;

  @override
  void initState() {
    super.initState();
    // Built here rather than lazily on the first round: a game closed on the
    // title screen would otherwise make its first ticker while the tree it
    // belongs to was being taken down.
    _clock = AnimationController(vsync: this, duration: widget.length)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _end();
      });
    _ending = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _reveal = CurvedAnimation(parent: _ending, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _reveal.dispose();
    _clock.dispose();
    _ending.dispose();
    super.dispose();
  }

  void _play(int seed) {
    // Made before the frame it goes on, because building a board walks it for
    // every word it holds.
    final round =
        Round.of(seed, lexicon: widget.lexicon, length: widget.length);
    setState(() {
      _round = round;
      _phase = Phase.playing;
      _beatBest = false;
      _go++;
    });
    _ending.value = 0;
    _clock.forward(from: 0);
  }

  void _fresh() => _play((widget.seeds ?? Round.freshSeed)());

  void _title() {
    _clock.stop();
    setState(() {
      _phase = Phase.title;
      _round = null;
    });
  }

  /// A word was taken. The board that comes back is the one the play area is
  /// already showing, so this only has to catch up with it.
  void _took(Board board) {
    if (_phase != Phase.playing) return;
    final round = _round!.on(board);
    setState(() => _round = round);

    // Nothing left to find. Making the player wait out the clock in front of
    // a board they have finished would be a punishment for winning.
    if (round.missed.isEmpty) _end();
  }

  Future<void> _end({bool ranOut = true}) async {
    if (_phase != Phase.playing) return;
    final round = _round!;
    _clock.stop();

    // The eye is on the letters, wherever the round's end came from, so the
    // phone says so the way it does when a word counts.
    HapticFeedback.heavyImpact();
    setState(() {
      _phase = Phase.over;
      _ranOut = ranOut;
      // Asked before it is saved, because saving it is what stops it being
      // true.
      _beatBest = round.score > widget.best.points;
    });
    _ending.forward(from: 0);

    await widget.best.record(points: round.score, seed: round.seed);
    // The card is already up and showing the old best, so it has to be built
    // again with what was just written.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;

    return PopScope(
      // Back goes one screen inwards rather than out of the game: out of a
      // round to what it came to, and off that card to the title. A player
      // who wants a different board should not have to lose the app to get
      // one, and should not lose the round they were in either.
      canPop: round == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_phase == Phase.playing) {
          _end(ranOut: false);
        } else {
          _title();
        }
      },
      child: Scaffold(
        backgroundColor: Palette.backdrop,
        body: round == null
            ? TitleScreen(best: widget.best, onPlay: _fresh)
            : Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    // The board is still there under the card, and a thumb
                    // dragged across it after the clock stopped must not spell
                    // anything.
                    ignoring: _phase != Phase.playing,
                    child: PlayArea(
                      key: ValueKey(_go),
                      board: round.board,
                      onBoard: _took,
                      above: Hud(
                        round: round,
                        clock: _clock,
                        best: widget.best.points,
                        onEnd: () => _end(ranOut: false),
                      ),
                      middle: FoundList(words: round.found),
                    ),
                  ),
                  if (_phase == Phase.over)
                    SummaryCard(
                      round: round,
                      best: widget.best,
                      ranOut: _ranOut,
                      beatBest: _beatBest,
                      reveal: _reveal,
                      onAgain: _fresh,
                      onSameAgain: () => _play(round.seed),
                      onTitle: _title,
                    ),
                ],
              ),
      ),
    );
  }
}
