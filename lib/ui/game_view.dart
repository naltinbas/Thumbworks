import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'game_loop.dart';
import 'world_painter.dart';

/// The run on the glass: a picture of the world, and a button the size of the
/// screen.
///
/// This is the only place in the game where a real clock exists. A [Ticker]
/// hands over the time since the run started, this works out how long the
/// last frame was, and the loop turns that into whole simulation steps. The
/// simulation never sees a frame time, so a phone that draws at a hundred and
/// twenty gets the same run as one that draws at sixty, only smoother.
class GameView extends StatefulWidget {
  const GameView({super.key, required this.loop});

  final GameLoop loop;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _previous = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    // The ticker counts from when it started, so the frame is the difference.
    // Its first tick is always zero, which is worth nothing and costs nothing.
    final frame = elapsed - _previous;
    _previous = elapsed;
    widget.loop.advance(frame);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // The whole screen is the button. A thumb on a phone should not have to
      // find anything, and there is only ever one thing to say.
      behavior: HitTestBehavior.opaque,
      // On the way down, not on the way up: a game that waits for the finger
      // to lift is a game that feels late, and the release is a moment the
      // player is timing to a tenth of a second.
      onTapDown: (_) => widget.loop.tap(),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: widget.loop,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            isComplex: true,
            painter: WorldPainter(
              world: widget.loop.world,
              focusY: widget.loop.focusY,
              trail: widget.loop.trail,
              flashes: widget.loop.flashes,
            ),
          ),
        ),
      ),
    );
  }
}
