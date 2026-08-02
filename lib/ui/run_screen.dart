import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../sim/field.dart';
import '../sim/kinds.dart';
import '../sim/run.dart';
import 'field_painter.dart';
import 'hud.dart';
import 'palette.dart';
import 'result_card.dart';

/// One run: the field, the shop, and the clock that drives them.
class RunScreen extends StatefulWidget {
  const RunScreen({super.key, required this.onLeave, this.opening});

  final VoidCallback onLeave;

  /// A run to start from. Only a test or a screenshot passes this.
  final Run? opening;

  @override
  State<RunScreen> createState() => RunScreenState();
}

class RunScreenState extends State<RunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Run _run;
  Tower? _placing;
  Cell? _chosen;
  bool _hurrying = false;
  bool _away = false;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  /// World time owed but not yet run.
  ///
  /// A frame is not a step. The simulation advances a sixtieth of a second at
  /// a time whatever the phone manages to draw, and this is what is left over
  /// between frames — kept rather than rounded away, because rounding it away
  /// is how a game runs at a different speed on a different phone.
  double _owed = 0;

  /// The most world time one frame may catch up on.
  ///
  /// Without a cap, a phone that stalls for two seconds comes back and runs a
  /// hundred and twenty steps in one frame, which stalls it again. Better to
  /// lose the time than to spiral.
  static const _mostPerFrame = 0.25;

  Run get run => _run;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _run = widget.opening ?? Run.fresh();
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
    // A run left on a bus is a run that should be where it was left, not one
    // that carried on without anybody watching.
    if (state == AppLifecycleState.resumed) return;
    if (_away) return;
    setState(() => _away = true);
  }

  void _comeBack() {
    if (!_away) return;
    setState(() => _away = false);
    _lastTick = Duration.zero;
    _owed = 0;
  }

  void _tick(Duration elapsed) {
    if (_run.isOver || _away) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final gap = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;

    _owed += gap * (_hurrying ? 2 : 1);
    if (_owed > _mostPerFrame) _owed = _mostPerFrame;

    var run = _run;
    var stepped = false;
    while (_owed >= Run.stepSeconds && !run.isOver) {
      run = run.step();
      _owed -= Run.stepSeconds;
      stepped = true;
    }
    if (!stepped) return;

    final ended = run.isOver && !_run.isOver;
    setState(() => _run = run);
    if (ended) HapticFeedback.heavyImpact();
  }

  void _tapped(Cell cell) {
    final placing = _placing;
    if (placing != null) {
      if (!_run.canBuildOn(cell) || _run.embers < placing.cost) {
        setState(() => _chosen = cell);
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        _run = _run.build(placing, cell);
        _placing = null;
        _chosen = null;
      });
      return;
    }

    setState(() => _chosen = _run.towerOn(cell) == null ? null : cell);
  }

  @override
  Widget build(BuildContext context) {
    final chosen = _chosen;
    final onTower = chosen != null && _run.towerOn(chosen) != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Ledger(run: _run, onLeave: widget.onLeave),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final metrics =
                              Metrics(Size(box.maxWidth, box.maxHeight));
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) {
                              final cell =
                                  metrics.under(details.localPosition);
                              if (cell != null) _tapped(cell);
                            },
                            child: CustomPaint(
                              size: Size(box.maxWidth, box.maxHeight),
                              painter: FieldPainter(
                                run: _run,
                                metrics: metrics,
                                placing: _placing,
                                chosen: _chosen,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Controls(
                    run: _run,
                    hurrying: _hurrying,
                    onCall: () => setState(() => _run = _run.callWave()),
                    onHurry: (on) => setState(() => _hurrying = on),
                  ),
                  if (onTower)
                    TowerPanel(
                      run: _run,
                      on: chosen,
                      onUpgrade: () =>
                          setState(() => _run = _run.upgrade(chosen)),
                      onSell: () => setState(() {
                        _run = _run.sell(chosen);
                        _chosen = null;
                      }),
                    )
                  else
                    Shop(
                      run: _run,
                      placing: _placing,
                      onPlace: (tower) => setState(() {
                        _placing = tower;
                        _chosen = null;
                      }),
                    ),
                ],
              ),
              if (_away)
                Positioned.fill(
                  child: Semantics(
                    button: true,
                    label: 'Paused. Tap to carry on.',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _comeBack,
                      child: ColoredBox(
                        color: Palette.veil,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Paused',
                                style: TextStyle(
                                  color: Palette.ink,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 6,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Tap to carry on',
                                style: TextStyle(
                                  color: Palette.ember,
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
                ),
              if (_run.isOver)
                ResultCard(
                  run: _run,
                  onAgain: () => setState(() {
                    _run = Run.fresh();
                    _placing = null;
                    _chosen = null;
                    _owed = 0;
                    _lastTick = Duration.zero;
                  }),
                  onLeave: widget.onLeave,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
