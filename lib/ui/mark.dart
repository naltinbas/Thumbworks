import 'package:flutter/material.dart';

import '../tune/tune.dart';
import 'palette.dart';

/// The mark: four notes above the line, one to a lane.
///
/// The whole game is four things falling at a line, so that is the picture.
/// The four colours are the four lanes, and they are what a player learns
/// first.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onStage = true});

  /// Whether to draw the dark square behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onStage;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onStage: onStage),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onStage});

  final bool onStage;

  /// How far down each note is, as a share of the height. Uneven on purpose:
  /// four notes in a row is a bar chart, four at different heights is a tune.
  static const _heights = [0.62, 0.34, 0.16, 0.46];

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onStage) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.14)),
        Paint()..color = Palette.night,
      );
      // The lanes, just visible.
      for (var lane = 0; lane < Tune.lanes; lane += 2) {
        canvas.drawRect(
          Rect.fromLTWH(
            box.left + lane * side / Tune.lanes,
            box.top,
            side / Tune.lanes,
            side,
          ),
          Paint()..color = Palette.stage,
        );
      }
    }

    final lane = side / Tune.lanes;
    final line = box.top + side * 0.82;

    canvas.drawRect(
      Rect.fromLTWH(box.left + side * 0.06, line, side * 0.88, side * 0.022),
      Paint()..color = Palette.line,
    );

    for (var i = 0; i < Tune.lanes; i++) {
      final note = Rect.fromCenter(
        center: Offset(
          box.left + (i + 0.5) * lane,
          box.top + side * _heights[i],
        ),
        width: lane * 0.66,
        height: lane * 0.30,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(note, Radius.circular(note.height * 0.36)),
        Paint()..color = Palette.of(i),
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onStage != onStage;
}
