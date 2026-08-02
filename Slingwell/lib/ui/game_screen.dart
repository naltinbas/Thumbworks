import 'dart:math';

import 'package:flutter/material.dart';

import '../best_run.dart';
import 'game_loop.dart';
import 'game_over_card.dart';
import 'game_view.dart';
import 'hud.dart';
import 'title_card.dart';

/// What the player is looking at.
///
/// The run underneath is always there and always ticking: on the title screen
/// the craft is already going round the first well, and after a crash the
/// wreck is still on the glass behind the score. These are only what is drawn
/// over the top of it.
enum Phase { title, running, over }

/// The game around a run: open on a title, start on a tap, show the score
/// while playing, and offer the next go the moment this one ends.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.best, this.seeds});

  /// How far the world is raised up the glass while the title is up, in
  /// metres.
  ///
  /// The words own the bottom of the screen and the craft swings around the
  /// first well, which is where the words are. Lifting it puts the swing in
  /// the clear part of the screen, which is the whole reason the run is
  /// running under the title. It settles back down when the player starts.
  ///
  /// The camera leaves at least seventeen metres above the height it is
  /// following on any screen shape, and the craft rides two metres out from
  /// the well, so this has room to spare. camera_test.dart holds that.
  static const titleLift = 10.0;

  final BestRun best;

  /// Where a new run's seed comes from. The game picks a fresh one each go;
  /// a test passes one in so it can play a world it has chosen.
  final int Function()? seeds;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static final Random _random = Random();

  /// Seeds are small on purpose. A player who wants to play their best run
  /// again, or tell someone else about it, has five digits to carry rather
  /// than ten.
  static int _freshSeed() => _random.nextInt(99999) + 1;

  late final GameLoop _loop;
  late final AnimationController _ending;
  late final Animation<double> _reveal;

  Phase _phase = Phase.title;
  bool _beatBest = false;

  @override
  void initState() {
    super.initState();
    _loop = GameLoop(seed: (widget.seeds ?? _freshSeed)())
      ..settleLift(GameScreen.titleLift)
      ..addListener(_onLoop);
    _ending = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _reveal = CurvedAnimation(parent: _ending, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _loop
      ..removeListener(_onLoop)
      ..dispose();
    _ending.dispose();
    super.dispose();
  }

  /// A run ends inside the simulation, on a step nobody asked about, so the
  /// screen watches the loop for it rather than checking during a build.
  void _onLoop() {
    if (_phase == Phase.running && _loop.world.isOver) _endRun();
  }

  Future<void> _endRun() async {
    final world = _loop.world;
    setState(() {
      _phase = Phase.over;
      // Asked before it is saved, because saving it is what stops it being
      // true.
      _beatBest = world.score > widget.best.score;
    });
    _ending.forward(from: 0);
    await widget.best.record(score: world.score, seed: world.seed);
    // The card is already up and is showing the old best, so it has to be
    // built again with what was just written.
    if (mounted) setState(() {});
  }

  /// The craft has been swinging round the first well since the app opened, so
  /// starting is not a matter of setting anything up: it is the same run, now
  /// being scored, and the player's next tap is a real release.
  void _start() {
    _loop.lift = 0;
    setState(() => _phase = Phase.running);
  }

  void _again() {
    _loop.restart(seed: (widget.seeds ?? _freshSeed)());
    _ending.value = 0;
    setState(() {
      _phase = Phase.running;
      _beatBest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameView(loop: _loop),
          if (_phase == Phase.running) Hud(loop: _loop, best: widget.best.score),
          if (_phase == Phase.title)
            TitleCard(best: widget.best, onStart: _start),
          if (_phase == Phase.over)
            GameOverCard(
              world: _loop.world,
              best: widget.best,
              beatBest: _beatBest,
              reveal: _reveal,
              onAgain: _again,
            ),
        ],
      ),
    );
  }
}
