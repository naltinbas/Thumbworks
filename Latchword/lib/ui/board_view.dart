import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../game/board.dart';
import 'board_painter.dart';
import 'grid_geometry.dart';
import 'tracer.dart';

/// The grid, and the drag that spells a word on it.
///
/// It owns the trace being dragged and nothing else: the board comes in from
/// above and the finished trace goes back out, so the thing that keeps score
/// decides what a word is worth.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.board,
    this.onTrace,
    this.onLift,
  });

  final Board board;

  /// Every change while a finger is down, for whatever is showing the word.
  final ValueChanged<Trace>? onTrace;

  /// The finger has gone. The trace is legal by construction, so all that is
  /// left to say about it is what the board says.
  final void Function(List<Spot> spots, Refusal verdict)? onLift;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Trace> _live = ValueNotifier(const Trace());

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  Tracer? _tracer;

  /// The finger the trace belongs to. A second one landing is ignored rather
  /// than allowed to drag the same trace somewhere else.
  int? _finger;

  @override
  void initState() {
    super.initState();
    _settle.addStatusListener((status) {
      if (status == AnimationStatus.completed) _show(const []);
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    _live.dispose();
    super.dispose();
  }

  void _show(List<Spot> spots, {Offset? thumb, bool settling = false}) {
    final was = _live.value;
    final trace = Trace(
      spots: spots,
      word: widget.board.wordFor(spots),
      verdict: widget.board.judge(spots),
      thumb: thumb,
      settling: settling,
    );
    _live.value = trace;

    // A thumb is over the board and cannot see most of it, so the two things
    // worth knowing arrive through the finger: another letter is in, and the
    // letters are now a word.
    final dragging = _finger != null;
    if (dragging && spots.length != was.spots.length) {
      HapticFeedback.selectionClick();
    }
    if (dragging && trace.isWord && !was.isWord) HapticFeedback.mediumImpact();

    widget.onTrace?.call(trace);
  }

  void _down(GridGeometry geometry, PointerDownEvent event) {
    if (_finger != null) return;
    _finger = event.pointer;
    _settle.reset();
    _tracer = Tracer(geometry)..begin(event.localPosition);
    _show(_tracer!.spots.toList(), thumb: event.localPosition);
  }

  void _move(PointerMoveEvent event) {
    final tracer = _tracer;
    if (tracer == null || event.pointer != _finger) return;
    tracer.extend(event.localPosition);
    _show(tracer.spots.toList(), thumb: event.localPosition);
  }

  void _up(PointerEvent event) {
    final tracer = _tracer;
    if (tracer == null || event.pointer != _finger) return;
    // Whatever was traced counts, wherever the finger happened to be when it
    // lifted. Letting go past the edge of the grid is how a trace that ends on
    // an outside square ends.
    final spots = tracer.spots.toList();
    _tracer = null;
    _finger = null;

    if (spots.isEmpty) {
      _show(const []);
    } else {
      _show(spots, settling: true);
      _settle.forward(from: 0);
    }
    widget.onLift?.call(spots, widget.board.judge(spots));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry =
            GridGeometry.fit(constraints.biggest, widget.board.size);
        return Listener(
          // Raw pointers rather than a drag recogniser: a pan does not start
          // until the finger has moved its slop, and half a square of dead
          // travel before the first letter lights is exactly the lag this
          // game cannot have.
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _down(geometry, event),
          onPointerMove: _move,
          onPointerUp: _up,
          // A pointer the system takes away mid-word is treated as a finger
          // lifting: a player who traced a word and then got a phone call
          // would rather keep it than be told nothing happened.
          onPointerCancel: _up,
          child: CustomPaint(
            size: Size.infinite,
            painter: BoardPainter(
              board: widget.board,
              live: _live,
              settle: _settle,
              letters: DefaultTextStyle.of(context).style,
            ),
          ),
        );
      },
    );
  }
}
