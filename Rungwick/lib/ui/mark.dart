import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: three rungs of a ladder, with one letter moved along it.
///
/// The whole game in one shape — the same word twice with a single tile
/// changed — and it reads at forty eight points, which is the size that
/// decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBoard = true});

  /// Whether to draw the board behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onBoard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onBoard: onBoard),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onBoard});

  final bool onBoard;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onBoard) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.board,
      );
    }

    // Three rows of three tiles, and the one that moved is a different
    // colour in each row — a letter walking down the ladder.
    const across = 3;
    const down = 3;
    final gap = side * 0.05;
    final tile = (side * 0.72 - gap * (across - 1)) / across;
    final left = box.left + (side - (tile * across + gap * (across - 1))) / 2;
    final top = box.top + (side - (tile * down + gap * (down - 1))) / 2;

    for (var row = 0; row < down; row++) {
      for (var column = 0; column < across; column++) {
        final moved = column == row;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + column * (tile + gap),
              top + row * (tile + gap),
              tile,
              tile,
            ),
            Radius.circular(tile * 0.22),
          ),
          Paint()..color = moved ? Palette.rope : Palette.rung,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onBoard != onBoard;
}
