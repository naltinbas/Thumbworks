import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../best.dart';
import '../sim/journey.dart';
import '../sim/library.dart';
import 'palette.dart';
import 'world_painter.dart';

/// The way in.
///
/// Behind the words, the game plays itself: a run driven by the stored proofs,
/// which is the same thing the tests use. It is the mark, and it is also the
/// claim — what is running behind the title is a run nobody is playing and
/// nothing is faking.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best best;
  final VoidCallback onPlay;

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late Journey _shown = _fresh();
  final _holds = <int>{};
  var _known = 0;
  Ticker? _ticker;
  Duration _last = Duration.zero;
  double _owed = 0;

  static Journey _fresh() => Journey.begin(seed: 5);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (_last == Duration.zero) {
      _last = elapsed;
      return;
    }
    _owed += (elapsed - _last).inMicroseconds / 1000000;
    _last = elapsed;
    if (_owed > 0.1) _owed = 0.1;

    var journey = _shown;
    while (_owed >= 1 / 120) {
      // Learn the presses for anything laid since last time, then press
      // exactly those. This is the same trick the tests use and the same one
      // the whole game rests on.
      for (; _known < journey.laid.length; _known++) {
        _holds.addAll(journey.laid[_known].holdsInRun);
      }
      journey = journey.step(holding: _holds.contains(journey.run.steps));
      _owed -= 1 / 120;
      if (journey.isOver) {
        journey = _fresh();
        _holds.clear();
        _known = 0;
        break;
      }
    }
    setState(() => _shown = journey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.sky,
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, box) => CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: WorldPainter(
                journey: _shown,
                metrics: Metrics(Size(box.maxWidth, box.maxHeight)),
              ),
            ),
          ),
          ColoredBox(color: Palette.sky.withValues(alpha: 0.55)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vaultline',
                    style: TextStyle(
                      color: Palette.ink,
                      fontSize: 42,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'One button. Hold it longer to go higher.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.inkDim,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.sky.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Palette.edge, width: 1.1),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Every stretch has been got through',
                          style: TextStyle(
                            color: Palette.good,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${Library.count} of them, each one played to the '
                          'end by a search over the same button you press.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Palette.inkDim,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: widget.onPlay,
                      style: FilledButton.styleFrom(
                        backgroundColor: Palette.good,
                        foregroundColor: Palette.sky,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Run',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.best.tiles == 0
                        ? 'no run yet'
                        : 'furthest ${widget.best.tiles}',
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
