import 'package:flutter/material.dart';

import 'palette.dart';

/// The mark: four squares of a plot, three turned over and one still shut,
/// with a flag standing in it.
///
/// It reads at forty eight points, which is the size that decides these
/// things: at that size a whole board is mush and four squares are not.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onGround = true});

  /// Whether to draw the ground behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onGround;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(onGround: onGround),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onGround});

  final bool onGround;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );

    if (onGround) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(side * 0.16)),
        Paint()..color = Palette.plot,
      );
    }

    // Four squares with a gap between them, filling the middle.
    final gap = side * 0.045;
    final cell = (side * 0.62 - gap) / 2;
    final left = box.left + (side - (cell * 2 + gap)) / 2;
    final top = box.top + (side - (cell * 2 + gap)) / 2;

    Rect squareAt(int row, int column) => Rect.fromLTWH(
          left + column * (cell + gap),
          top + row * (cell + gap),
          cell,
          cell,
        );

    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 2; column++) {
        final shut = row == 0 && column == 1;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            squareAt(row, column),
            Radius.circular(cell * 0.16),
          ),
          Paint()..color = shut ? Palette.shut : Palette.furrow,
        );
      }
    }

    // The flag: a pole with a pennant, in the one square still shut.
    final square = squareAt(0, 1);
    final pole = Paint()
      ..color = Palette.ink
      ..strokeWidth = cell * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(square.center.dx + cell * 0.06, square.top + cell * 0.20),
      Offset(square.center.dx + cell * 0.06, square.bottom - cell * 0.20),
      pole,
    );
    canvas.drawPath(
      Path()
        ..moveTo(square.center.dx + cell * 0.06, square.top + cell * 0.20)
        ..lineTo(square.center.dx - cell * 0.30, square.top + cell * 0.36)
        ..lineTo(square.center.dx + cell * 0.06, square.top + cell * 0.52)
        ..close(),
      Paint()..color = Palette.ember,
    );

    // And one square that has already gone up, in the corner opposite it.
    final blown = squareAt(1, 0);
    canvas.drawCircle(blown.center, cell * 0.20, Paint()..color = Palette.mine);
    final spine = Paint()
      ..color = Palette.mine
      ..strokeWidth = cell * 0.075
      ..strokeCap = StrokeCap.round;
    for (final way in const [Offset(1, 0), Offset(0, 1)]) {
      canvas.drawLine(
        blown.center - way * cell * 0.34,
        blown.center + way * cell * 0.34,
        spine,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onGround != onGround;
}
