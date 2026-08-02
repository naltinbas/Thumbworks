import 'package:flutter/material.dart';

import '../game/grid.dart';
import 'cell_painter.dart';

/// One cell on screen, and the thing a thumb actually hits.
///
/// The tile owns no game state. It is handed the cell as it now stands and
/// animates towards it, which keeps the rule in [Board] and the picture here.
class WireTile extends StatefulWidget {
  const WireTile({
    super.key,
    required this.cell,
    required this.lit,
    this.onTap,
  });

  final Cell cell;

  /// Whether current reaches this cell, as [Board.powered] sees it.
  final bool lit;

  /// Null for a cell there is no point tapping, which also drops it out of
  /// the tap targets rather than swallowing the touch.
  final VoidCallback? onTap;

  /// Short enough that tapping four times in a row still feels immediate.
  static const turnDuration = Duration(milliseconds: 220);

  /// Slower than the turn, so light spreading across the board reads as a
  /// consequence of the move rather than as part of it.
  static const lightDuration = Duration(milliseconds: 280);

  @override
  State<WireTile> createState() => _WireTileState();
}

class _WireTileState extends State<WireTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WireTile.turnDuration,
    // Starts settled: a tile that has not been turned yet is not mid-turn.
    value: 1,
  );

  // The overshoot is what sells the quarter turn as a physical flick.
  late final CurvedAnimation _spin =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

  @override
  void didUpdateWidget(WireTile old) {
    super.didUpdateWidget(old);
    // Exactly one quarter more than last time means the player turned this
    // cell. Any other change is a different board arriving, which should
    // appear rather than spin.
    if (widget.cell.turns == old.cell.turns + 1) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _controller.dispose();
    super.dispose();
  }

  String? get _label => switch (widget.cell.kind) {
        CellKind.source => 'source',
        CellKind.lamp => widget.lit ? 'lit lamp' : 'unlit lamp',
        CellKind.wire => widget.lit ? 'live wire' : 'dead wire',
        CellKind.empty => null,
      };

  @override
  Widget build(BuildContext context) {
    final target = widget.lit ? 1.0 : 0.0;
    // Merged so a screen reader gets one node per cell carrying both what the
    // cell is and that it can be turned.
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Semantics(
          label: _label,
          // Begin equals end so a tile that is lit when it first appears is
          // already lit, and only a change animates.
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: target, end: target),
            duration: WireTile.lightDuration,
            curve: Curves.easeOut,
            builder: (context, lit, _) => AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: CellPainter(
                  cell: widget.cell,
                  lit: lit,
                  spin: _spin.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
