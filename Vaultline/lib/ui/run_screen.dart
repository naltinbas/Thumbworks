import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../best.dart';
import '../sim/journey.dart';
import '../sim/runner.dart';
import 'hud.dart';
import 'over_card.dart';
import 'palette.dart';
import 'world_painter.dart';

/// One run.
class RunScreen extends StatefulWidget {
  const RunScreen({
    super.key,
    required this.seed,
    required this.best,
    required this.onLeave,
    required this.onAgain,
    this.opening,
  });

  final int seed;
  final Best best;
  final VoidCallback onLeave;

  /// Start another one, with a new seed.
  final VoidCallback onAgain;

  /// A journey to start from. Only a test or a screenshot passes this.
  final Journey? opening;

  @override
  State<RunScreen> createState() => RunScreenState();
}

class RunScreenState extends State<RunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Journey _journey;
  bool _holding = false;
  bool _away = false;
  bool _beat = false;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  /// World time owed but not yet run.
  ///
  /// A frame is not a step. The runner advances a hundred and twentieth of a
  /// second at a time whatever the phone manages to draw, and this is what is
  /// left over between frames — kept rather than rounded away, because
  /// rounding it away is how a jump clears a gap on one phone and not another.
  double _owed = 0;

  /// The most world time one frame may catch up on. Without a cap, a phone
  /// that stalls comes back and runs a second of game in one frame, which is
  /// a death nobody saw coming.
  static const _mostPerFrame = 0.1;

  Journey get journey => _journey;
  bool get holding => _holding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _journey = widget.opening ?? Journey.begin(seed: widget.seed);
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A run cannot be paused mid-jump and picked up fairly, so leaving the
    // game holds everything still until the player says go. Carrying on
    // without them would be a death they did not see.
    if (state == AppLifecycleState.resumed) return;
    if (_away || _journey.isOver) return;
    setState(() {
      _away = true;
      _holding = false;
    });
  }

  void _comeBack() {
    if (!_away) return;
    setState(() => _away = false);
    _lastTick = Duration.zero;
    _owed = 0;
  }

  void _tick(Duration elapsed) {
    if (_journey.isOver || _away) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final gap = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;

    _owed += gap;
    if (_owed > _mostPerFrame) _owed = _mostPerFrame;

    var journey = _journey;
    var stepped = false;
    while (_owed >= Run.stepSeconds && !journey.isOver) {
      journey = journey.step(holding: _holding);
      _owed -= Run.stepSeconds;
      stepped = true;
    }
    if (!stepped) return;

    final ended = journey.isOver && !_journey.isOver;
    setState(() => _journey = journey);
    if (ended) _finish();
  }

  Future<void> _finish() async {
    HapticFeedback.heavyImpact();
    final beat = await widget.best.record(_journey.score);
    if (!mounted) return;
    setState(() => _beat = beat);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.sky,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The whole screen is the button. A runner with a button in the
            // corner is a runner played with one eye on the corner.
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) {
                if (!_journey.isOver) setState(() => _holding = true);
              },
              onPointerUp: (_) => setState(() => _holding = false),
              onPointerCancel: (_) => setState(() => _holding = false),
              child: LayoutBuilder(
                builder: (context, box) => CustomPaint(
                  size: Size(box.maxWidth, box.maxHeight),
                  painter: WorldPainter(
                    journey: _journey,
                    metrics: Metrics(Size(box.maxWidth, box.maxHeight)),
                  ),
                ),
              ),
            ),
            SafeArea(
              // Pinned to the top. A Row inside a SafeArea filling a Stack
              // sits in the middle of the screen, which is where the game is.
              child: Align(
                alignment: Alignment.topCenter,
                child: Ledger(
                  tiles: _journey.score,
                  best: widget.best.tiles,
                  onLeave: widget.onLeave,
                ),
              ),
            ),
            if (_away)
              // The cover takes the touch itself. A box laid over the game is
              // hit first whatever is underneath it, so without this the tap
              // meant to carry on lands on nothing at all.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _comeBack,
                  child: ColoredBox(
                    color: Palette.veil.withValues(alpha: 0.92),
                    child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Held',
                          style: TextStyle(
                            color: Palette.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Touch to carry on',
                          style: TextStyle(
                            color: Palette.good,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_journey.isOver)
              OverCard(
                journey: _journey,
                best: widget.best.tiles,
                beat: _beat,
                onAgain: widget.onAgain,
                onLeave: widget.onLeave,
              ),
          ],
        ),
      ),
    );
  }
}
