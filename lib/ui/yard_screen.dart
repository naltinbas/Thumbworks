import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../yard/haul.dart';
import '../yard/levels.dart';
import '../yard/yard.dart';
import 'hud.dart';
import 'palette.dart';
import 'result_card.dart';
import 'yard_painter.dart';

/// One yard: shove the crates onto the marks.
class YardScreen extends StatefulWidget {
  const YardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, with the shoves it took, the first time a yard is finished.
  /// Answers whether that was the fewest yet.
  final Future<bool> Function(int shoves)? onDone;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  late Level _level;
  late Hauler _hauler;
  late Yard _yard;

  /// Every position since the start, so anything can be taken back.
  final _before = <Yard>[];

  /// The crate the game is pointing at, and which way it says to shove it.
  int? _pointAt;
  Way? _pointWay;

  String? _saying;
  var _thinking = false;
  var _best = false;
  var _told = false;

  Level get level => _level;
  Yard get yard => _yard;
  String? get saying => _saying;
  int? get pointAt => _pointAt;

  /// The crate that can no longer be moved to a mark, if there is one.
  int? get spoiled {
    final moved = _yard.moved;
    if (moved == null) return null;
    return _hauler.isLostAt(_yard, [moved]) ? moved : null;
  }

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(YardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) _open();
  }

  void _open() {
    _level = Levels.at(widget.number);
    _hauler = Hauler(_level.ground);
    setState(() {
      _yard = _level.start;
      _before.clear();
      _pointAt = null;
      _pointWay = null;
      _saying = null;
      _best = false;
      _told = false;
    });
  }

  void _goTo(Yard next, {bool remember = true}) {
    setState(() {
      if (remember) _before.add(_yard);
      _yard = next;
      _pointAt = null;
      _pointWay = null;
      // A crate that has just been spoiled says so. This is the cheap check,
      // not a search: a crate against a wall it can never leave, or in a block
      // of four that can never move again. It is instant, and it is the
      // mistake people actually make.
      final moved = next.moved;
      _saying = moved != null && _hauler.isLostAt(next, [moved])
          ? 'That crate cannot reach a mark any more. Undo.'
          : null;
    });
    if (next.isDone) _finished();
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_yard.pushes).then((best) {
      if (mounted && best) setState(() => _best = true);
    });
  }

  /// A step, from a swipe.
  void _push(Way way) {
    if (_yard.isDone) return;
    final next = _yard.step(way);
    if (next == null) return;
    if (next.pushes > _yard.pushes) HapticFeedback.selectionClick();
    _goTo(next);
  }

  /// A tap: walk there if it can be walked to, or shove a crate that is
  /// next to the hauler and in line with them.
  void _touched(int at) {
    if (_yard.isDone) return;

    if (_yard.hasCrate(at)) {
      for (final way in Way.values) {
        if (_level.ground.beyond(_yard.hauler, way) == at) {
          _push(way);
          return;
        }
      }
      return;
    }

    final steps = _yard.walkTo(at);
    if (steps == null || steps.isEmpty) return;
    // Walking costs nothing, so a tap across the yard is one move as far as
    // anything that counts is concerned. It is still one position on the undo
    // list, because taking back a walk you did not mean is worth having.
    var walked = _yard;
    for (final way in steps) {
      walked = walked.step(way)!;
    }
    _goTo(walked);
  }

  void _undo() {
    if (_before.isEmpty) return;
    setState(() {
      _yard = _before.removeLast();
      _pointAt = null;
      _pointWay = null;
      _saying = null;
    });
  }

  void _reset() {
    setState(() {
      _yard = _level.start;
      _before.clear();
      _pointAt = null;
      _pointWay = null;
      _saying = null;
    });
  }

  /// Asked. Searches from where the yard actually is now, which is the only
  /// honest answer — a hint off the shortest way through from the start is
  /// advice about a yard nobody is playing.
  void _ask() {
    if (_yard.isDone) return;
    setState(() => _thinking = true);

    final haul = _hauler.from(_yard);
    setState(() {
      _thinking = false;
      if (!haul.canBeDone) {
        _pointAt = null;
        _pointWay = null;
        _saying = 'This cannot be finished from here. Undo, or start again.';
        return;
      }
      final first = haul.line.first;
      _pointAt = first.crate;
      _pointWay = first.way;
      final left = haul.pushes! + _yard.pushes;
      _saying = 'Shove that one ${first.way.name}. '
          'From here it takes ${haul.pushes} more'
          '${left == _level.par ? ', which is still the fewest there are.' : '.'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            children: [
              Ledger(
                number: widget.number,
                level: _level,
                yard: _yard,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final metrics = Metrics(
                      Size(box.maxWidth, box.maxHeight),
                      _level.across,
                      _level.down,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (touch) {
                        final at = metrics.under(touch.localPosition);
                        if (at != null) _touched(at);
                      },
                      onHorizontalDragEnd: (swipe) {
                        final speed = swipe.velocity.pixelsPerSecond.dx;
                        if (speed.abs() < 60) return;
                        _push(speed > 0 ? Way.right : Way.left);
                      },
                      onVerticalDragEnd: (swipe) {
                        final speed = swipe.velocity.pixelsPerSecond.dy;
                        if (speed.abs() < 60) return;
                        _push(speed > 0 ? Way.down : Way.up);
                      },
                      child: CustomPaint(
                        size: Size(box.maxWidth, box.maxHeight),
                        painter: YardPainter(
                          yard: _yard,
                          metrics: metrics,
                          pointAt: _pointAt,
                          pointWay: _pointWay,
                          spoiled: spoiled,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_yard.isDone)
                ResultCard(
                  level: _level,
                  yard: _yard,
                  best: _best,
                  onAgain: _reset,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                Tools(
                  canUndo: _before.isNotEmpty,
                  saying: _saying,
                  thinking: _thinking,
                  onUndo: _undo,
                  onReset: _reset,
                  onAsk: _ask,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
