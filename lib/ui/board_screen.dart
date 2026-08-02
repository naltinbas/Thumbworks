import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../sim/levels.dart';
import '../sim/shapes.dart';
import '../sim/stroke.dart';
import '../sim/world.dart';
import 'hud.dart';
import 'palette.dart';
import 'slate_painter.dart';
import 'result_card.dart';

/// One level: draw, then watch.
class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onSolved,
    this.opening,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, with the chalk it took, the first time a run reaches the
  /// ring. Once: a player who watches the same win twice has not solved it
  /// twice, and the second one is not a tidier answer than the first.
  final void Function(double chalk)? onSolved;

  /// A drawing to start with. Only a test or a screenshot passes this.
  final Drawing? opening;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen>
    with SingleTickerProviderStateMixin {
  late Level _level;
  late Drawing _drawing;

  /// The stroke under the finger, if there is one.
  Stroke? _drawingNow;

  /// The run, once it has been let go. Null while still drawing.
  World? _world;

  /// Where the ball has been this run, for the line it leaves behind.
  final _trail = <Spot>[];

  /// Whether this level's win has already been written down.
  bool _told = false;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  /// World time owed but not yet run.
  double _owed = 0;

  /// The most world time one frame may catch up on.
  static const _mostPerFrame = 0.08;

  Level get level => _level;
  Drawing get drawing => _drawing;
  World? get world => _world;
  bool get running => _world != null;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(BoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) _open();
  }

  void _open() {
    setState(() {
      _level = Levels.at(widget.number);
      _drawing = widget.opening ?? Drawing.with_(_level.ink);
      _drawingNow = null;
      _world = null;
      _trail.clear();
    });
    _ticker?.dispose();
    _ticker = null;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _go() {
    if (running) return;
    HapticFeedback.selectionClick();
    setState(() {
      _world = _level.worldWith(_drawing);
      _trail
        ..clear()
        ..add(_level.start);
    });
    _lastTick = Duration.zero;
    _owed = 0;
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final world = _world;
    if (world == null || world.isOver) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    _owed += (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (_owed > _mostPerFrame) _owed = _mostPerFrame;

    var now = world;
    var stepped = false;
    while (_owed >= World.stepSeconds && !now.isOver) {
      now = now.step();
      _owed -= World.stepSeconds;
      stepped = true;
      if (now.steps % 6 == 0) _trail.add(now.ball);
    }
    if (!stepped) return;

    final ended = now.isOver;
    setState(() => _world = now);
    if (ended) {
      _trail.add(now.ball);
      HapticFeedback.mediumImpact();
      if (now.ending == Ending.home && !_told) {
        _told = true;
        widget.onSolved?.call(_drawing.used);
      }
    }
  }

  void _again() {
    _ticker?.dispose();
    _ticker = null;
    setState(() {
      _world = null;
      _trail.clear();
    });
  }

  void _rub() {
    if (running) return;
    setState(() {
      _drawing = _drawing.back;
      _drawingNow = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final world = _world;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.slateDeep,
        // A column, not a stack: when the run is over the card takes the room
        // it needs and the board gives it up. Over the top of the board it
        // would cover the bottom of it, which on half these levels is where
        // the ring is — and the picture of how the ball got there is the one
        // thing worth looking at at the end of a run.
        body: SafeArea(
          child: Column(
            children: [
              Ledger(
                number: widget.number,
                level: _level,
                drawing: _drawing,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final metrics = Metrics(Size(box.maxWidth, box.maxHeight));
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) =>
                          _touched(metrics, event.localPosition),
                      onPointerMove: (event) =>
                          _dragged(metrics, event.localPosition),
                      onPointerUp: (_) => _lifted(),
                      onPointerCancel: (_) => _lifted(),
                      child: CustomPaint(
                        size: Size(box.maxWidth, box.maxHeight),
                        painter: SlatePainter(
                          level: _level,
                          drawing: _drawing,
                          metrics: metrics,
                          world: world,
                          drawingNow: _drawingNow,
                          trail: List<Spot>.from(_trail),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (world != null && world.isOver)
                ResultCard(
                  level: _level,
                  world: world,
                  drawing: _drawing,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                Tools(
                  running: running,
                  canRub: _drawing.strokes.isNotEmpty,
                  onGo: _go,
                  onRub: _rub,
                  onAgain: _again,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _touched(Metrics metrics, Offset at) {
    if (running) return;
    setState(() => _drawingNow = Stroke([metrics.toWorld(at)]));
  }

  void _dragged(Metrics metrics, Offset at) {
    final drawing = _drawingNow;
    if (drawing == null || running) return;
    setState(() => _drawingNow = drawing.to(metrics.toWorld(at)));
  }

  void _lifted() {
    final stroke = _drawingNow;
    if (stroke == null) return;
    setState(() {
      _drawing = _drawing.add(stroke);
      _drawingNow = null;
    });
  }
}
