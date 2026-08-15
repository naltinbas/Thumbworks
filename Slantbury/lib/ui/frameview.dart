import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pieces/geometry.dart';
import '../pieces/play.dart';
import 'palette.dart';

/// Where the frame and the tray lie on the board, so the screen and the
/// tests can find every square and every piece: the frame across the
/// top, y running up as it does on paper, and the four pieces' tray
/// along the bottom.
class Metrics {
  Metrics(this.play, Size room, {this.bare = false}) {
    final rules = play.rules;
    final band = bare ? room.height * 0.9 : room.height * 0.58;
    unit = math.min(room.width * 0.92 / rules.width, band / rules.height);
    final frameWidth = unit * rules.width, frameHeight = unit * rules.height;
    origin = Offset((room.width - frameWidth) / 2, (bare ? (room.height - frameHeight) / 2 : room.height * 0.03 + (band - frameHeight) / 2));
    frameRect = Rect.fromLTWH(origin.dx, origin.dy, frameWidth, frameHeight);
    trayTop = room.height * 0.66;
    trayHeight = room.height * 0.3;
    slotWidth = room.width / 4;
  }

  final Play play;
  final bool bare;

  late final double unit;
  late final Offset origin;
  late final Rect frameRect;
  late final double trayTop;
  late final double trayHeight;
  late final double slotWidth;

  /// A frame point on the board.
  Offset at(Pt p) => Offset(origin.dx + p.$1.asDouble * unit, origin.dy + (play.rules.height - p.$2.asDouble) * unit);

  /// The lower-left corner of the square (x, y) on the board.
  Offset cornerAt(int x, int y) => at(pt(x, y));

  /// The middle of the square (x, y).
  Offset middleOf(int x, int y) => cornerAt(x, y) + Offset(unit / 2, -unit / 2);

  /// The square under a touch, or null off the frame.
  (int, int)? squareUnder(Offset touch) {
    if (!frameRect.contains(touch)) return null;
    final x = ((touch.dx - origin.dx) / unit).floor();
    final y = ((frameRect.bottom - touch.dy) / unit).floor();
    return (x.clamp(0, play.rules.width - 1), y.clamp(0, play.rules.height - 1));
  }

  /// The laid piece under a touch, or null.
  int? laidUnder(Offset touch) {
    if (!frameRect.contains(touch)) return null;
    final fx = (touch.dx - origin.dx) / unit, fy = (frameRect.bottom - touch.dy) / unit;
    // The last piece drawn lies on top, so it is the one under the touch.
    for (var p = 3; p >= 0; p--) {
      final corners = play.cornersOf(p);
      if (corners == null) continue;
      if (_inside(corners, fx, fy)) return p;
    }
    return null;
  }

  static bool _inside(List<Pt> poly, double x, double y) {
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i], b = poly[(i + 1) % poly.length];
      final side = (b.$1.asDouble - a.$1.asDouble) * (y - a.$2.asDouble) - (b.$2.asDouble - a.$2.asDouble) * (x - a.$1.asDouble);
      if (side < -1e-9) return false;
    }
    return true;
  }

  /// The tray slot under a touch, or null.
  int? slotUnder(Offset touch) {
    if (touch.dy < trayTop || touch.dy > trayTop + trayHeight) return null;
    final p = (touch.dx / slotWidth).floor().clamp(0, 3);
    return p;
  }

  /// Piece [p] drawn in its tray slot as it lies in hand: its corners on
  /// the board.
  List<Offset> trayCorners(int p) {
    final (t, f) = play.ways[p];
    final pts = play.rules.pieces[p].turned(t, f);
    var w = 0, h = 0;
    for (final (x, y) in pts) {
      if (x > w) w = x;
      if (y > h) h = y;
    }
    final scale = math.min(slotWidth * 0.8 / (w + 0.01), trayHeight * 0.7 / (h + 0.01));
    final left = slotWidth * p + (slotWidth - w * scale) / 2;
    final bottom = trayTop + trayHeight * 0.85;
    return [for (final (x, y) in pts) Offset(left + x * scale, bottom - y * scale)];
  }
}

/// The frame and the tray: the bare frame in rose with its grid, the
/// pieces laid in their colours, the area two share in rust, the pieces
/// still in the tray below, the one in hand ringed in chalk.
class FrameView extends CustomPainter {
  FrameView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the tray and the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final rules = play.rules;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.night);
    // The frame.
    canvas.drawRect(m.frameRect.inflate(m.unit * 0.12), Paint()..color = Palette.frame);
    canvas.drawRect(m.frameRect, Paint()..color = Palette.bare);
    for (var x = 1; x < rules.width; x++) {
      canvas.drawLine(Offset(m.origin.dx + x * m.unit, m.frameRect.top), Offset(m.origin.dx + x * m.unit, m.frameRect.bottom), Paint()
        ..color = Palette.grid
        ..strokeWidth = 1);
    }
    for (var y = 1; y < rules.height; y++) {
      canvas.drawLine(Offset(m.frameRect.left, m.origin.dy + y * m.unit), Offset(m.frameRect.right, m.origin.dy + y * m.unit), Paint()
        ..color = Palette.grid
        ..strokeWidth = 1);
    }
    // The pieces laid.
    for (var p = 0; p < 4; p++) {
      final corners = play.cornersOf(p);
      if (corners == null) continue;
      final path = _path(corners.map(m.at).toList());
      canvas.drawPath(path, Paint()..color = Palette.pieces[p]);
      canvas.drawPath(path, Paint()
        ..color = Palette.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, m.unit * 0.03)
        ..strokeJoin = StrokeJoin.round);
      if (!bare) {
        var cx = 0.0, cy = 0.0;
        for (final c in corners) {
          cx += m.at(c).dx;
          cy += m.at(c).dy;
        }
        _write(canvas, '${p + 1}', Offset(cx / corners.length, cy / corners.length), labels.copyWith(color: Palette.outline, fontSize: math.max(10, m.unit * 0.6), fontWeight: FontWeight.w800));
      }
    }
    // The area two pieces share, in rust.
    for (final (_, poly) in play.overlaps) {
      final path = _path(poly.map(m.at).toList());
      canvas.drawPath(path, Paint()..color = Palette.clash);
      canvas.drawPath(path, Paint()
        ..color = Palette.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
    // The pointer: the aimed laying ghosted, and the square ringed; or
    // the piece to lift ringed in rust.
    final aim = pointing;
    if (aim != null) {
      final (what, p) = aim;
      if (what == 'lay') {
        final target = Play.aimFor(play.level)![p];
        final ghost = rules.laid(p, target).map(m.at).toList();
        canvas.drawPath(_path(ghost), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
        canvas.drawCircle(m.middleOf(target.x, target.y), m.unit * 0.45, Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      } else {
        final corners = play.cornersOf(p);
        if (corners != null) {
          canvas.drawPath(_path(corners.map(m.at).toList()), Paint()
            ..color = Palette.clash
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4);
        }
      }
    }
    if (bare) return;
    // The tray.
    canvas.drawRect(Rect.fromLTWH(0, m.trayTop, size.width, m.trayHeight), Paint()..color = Palette.tray);
    for (var p = 0; p < 4; p++) {
      final slot = Rect.fromLTWH(m.slotWidth * p + 4, m.trayTop + 4, m.slotWidth - 8, m.trayHeight - 8);
      canvas.drawRRect(RRect.fromRectAndRadius(slot, const Radius.circular(8)), Paint()
        ..color = play.held == p ? Palette.chalk : Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = play.held == p ? 2.5 : 1);
      _write(canvas, rules.pieces[p].name, Offset(slot.center.dx, slot.top + 10), labels.copyWith(color: play.held == p ? Palette.ink : Palette.inkDim, fontSize: 11));
      if (play.laidDown(p)) {
        _write(canvas, 'laid', slot.center, labels.copyWith(color: Palette.inkDim, fontSize: 12));
        continue;
      }
      final path = _path(m.trayCorners(p));
      canvas.drawPath(path, Paint()..color = Palette.pieces[p]);
      canvas.drawPath(path, Paint()
        ..color = Palette.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round);
    }
  }

  Path _path(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(FrameView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a frame as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final frameArea = rules.width * rules.height, square = level.side * level.side;
  if (!level.winnable) {
    return 'The frame is ${rules.width} by ${rules.height}, $frameArea squares, and the four '
        'pieces have $square between them, cut from the ${level.side}-square; laid '
        'inside with no overlap they leave ${frameArea - square} square bare whatever '
        'else they do, and every one of the ${_commas(level.layings)} layings was swept '
        'to be sure, the areas found by exact fractions. Cassini\'s identity says '
        'the same of every frame of the kind: a Fibonacci number squared and the '
        'product of its two neighbours differ by one.$note';
  }
  return 'The sweep lays the four pieces every way inside the frame, turned and '
      'flipped, ${_commas(level.layings)} layings, and finds the area any two share '
      'and the squares left bare by exact fractions; ${level.ways} layings meet '
      'the ask. The areas say the rest: the frame has $frameArea squares and the '
      'pieces $square, so ${frameArea == square ? 'the pieces can fill it exactly' : frameArea > square ? '${frameArea - square} square must stay bare' : '${square - frameArea} square must be shared'}, '
      'and Cassini\'s identity says so for every frame of the kind, a Fibonacci '
      'number squared and the product of its two neighbours differing by one.$note';
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
