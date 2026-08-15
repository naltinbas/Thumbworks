import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stall/play.dart';
import 'palette.dart';

/// Where things lie on the board: a row of doors across the top, one
/// case shown, the pick on the first door and the cart behind the
/// second; and below it the table of every case, the cart's door down
/// the side and the pick across, each cell the policy's chance there.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final n = play.doors;
    doorGap = room.width * 0.9 / n;
    doorWidth = math.min(doorGap * 0.8, room.height * (bare ? 0.5 : 0.16));
    doorHeight = math.min(doorWidth * 1.6, room.height * (bare ? 0.7 : 0.3));
    doorsTop = bare ? (room.height - doorHeight) / 2 : room.height * 0.05;
    tableTop = room.height * 0.46;
    cell = math.min(room.width * 0.7 / n, room.height * 0.42 / n);
    tableLeft = (room.width - cell * n) / 2 + room.width * 0.04;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double doorGap;
  late final double doorWidth;
  late final double doorHeight;
  late final double doorsTop;
  late final double tableTop;
  late final double cell;
  late final double tableLeft;

  /// Door [i]'s rectangle.
  Rect door(int i) => Rect.fromLTWH((width - doorGap * play.doors) / 2 + i * doorGap + (doorGap - doorWidth) / 2, doorsTop, doorWidth, doorHeight);

  /// The table cell for the cart behind [cart] and the pick on [pick].
  Rect tableCell(int cart, int pick) => Rect.fromLTWH(tableLeft + pick * cell, tableTop + cart * cell, cell, cell);
}

/// The stall: the doors, one case shown, and the table of all the cases
/// shaded by the policy's chance in each.
class StallView extends CustomPainter {
  StallView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final String? pointing;
  final TextStyle labels;

  /// Whether to draw the doors alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.stall);
    final n = play.doors, k = play.opened;
    // The case shown: the pick on door 0, the cart behind door 1, the
    // host opening the last k doors, all goats.
    const pick = 0, cart = 1;
    for (var i = 0; i < n; i++) {
      final r = m.door(i);
      final opened = i >= n - k;
      final round = Radius.circular(r.width * 0.12);
      if (opened) {
        canvas.drawRRect(RRect.fromRectAndRadius(r, round), Paint()..color = Palette.open);
        _goat(canvas, r);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(r, round), Paint()..color = i == pick ? Palette.doorPicked : Palette.door);
        canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(r.width * 0.12), round), Paint()..color = (i == pick ? Palette.doorPicked : Palette.door).withValues(alpha: 0.6));
        canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(r.width * 0.12), round), Paint()
          ..color = Palette.doorDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = (r.width * 0.05).clamp(1.0, 3.0));
        canvas.drawCircle(Offset(r.right - r.width * 0.25, r.center.dy), (r.width * 0.06).clamp(1.5, 5.0), Paint()..color = Palette.doorDark);
      }
      if (!bare) {
        _write(canvas, '${i + 1}', Offset(r.center.dx, r.bottom + 10), labels.copyWith(color: i == pick ? Palette.doorPicked : Palette.inkDim, fontSize: 11, fontWeight: i == pick ? FontWeight.w800 : FontWeight.w400));
      }
      if (i == cart && !bare) {
        _cart(canvas, Rect.fromCenter(center: Offset(r.center.dx, r.top - r.height * 0.18), width: r.width * 0.9, height: r.height * 0.22));
      }
    }
    if (bare) return;
    _write(canvas, 'the pick on door 1, the cart behind door 2, the host opening $k goat${k == 1 ? '' : 's'}: one case of ${n * n}', Offset(size.width / 2, m.doorsTop + m.doorHeight + 26), labels.copyWith(color: Palette.inkDim, fontSize: 11));

    // The table.
    for (var c = 0; c < n; c++) {
      for (var p = 0; p < n; p++) {
        final r = m.tableCell(c, p).deflate(1);
        final Color colour;
        if (play.switching) {
          colour = c == p ? Palette.cellLose : Palette.cellPart.withValues(alpha: 0.35 + 0.65 / (n - 1 - k));
        } else {
          colour = c == p ? Palette.cellWin : Palette.cellLose;
        }
        canvas.drawRect(r, Paint()..color = colour);
      }
    }
    _write(canvas, 'pick', Offset(m.tableLeft + m.cell * n / 2, m.tableTop - 10), labels.copyWith(color: Palette.inkDim, fontSize: 11));
    canvas.save();
    canvas.translate(m.tableLeft - 10, m.tableTop + m.cell * n / 2);
    canvas.rotate(-math.pi / 2);
    _write(canvas, 'cart', Offset.zero, labels.copyWith(color: Palette.inkDim, fontSize: 11));
    canvas.restore();
    final chance = play.chance;
    final winWords = play.switching
        ? 'switching wins ${chance.$1} in ${chance.$2}: the ${n * n - n} off-cell cases, each ${(1, n - 1 - k) == (1, 1) ? 'sure' : '1 in ${n - 1 - k}'}'
        : 'staying wins ${chance.$1} in ${chance.$2}: the $n cases down the middle';
    _write(canvas, winWords, Offset(size.width / 2, m.tableTop + m.cell * n + 16), labels.copyWith(color: Palette.ink, fontSize: 12, fontWeight: FontWeight.w800));
  }

  void _goat(Canvas canvas, Rect r) {
    final c = Offset(r.center.dx, r.center.dy + r.height * 0.1);
    final w = r.width * 0.5, h = r.height * 0.22;
    canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h), Paint()..color = Palette.goat);
    canvas.drawCircle(Offset(c.dx + w * 0.45, c.dy - h * 0.55), h * 0.4, Paint()..color = Palette.goat);
    final leg = Paint()
      ..color = Palette.goat
      ..strokeWidth = (w * 0.08).clamp(1.0, 3.0);
    for (final dx in [-w * 0.3, -w * 0.1, w * 0.1, w * 0.3]) {
      canvas.drawLine(Offset(c.dx + dx, c.dy + h * 0.3), Offset(c.dx + dx, c.dy + h * 1.0), leg);
    }
  }

  void _cart(Canvas canvas, Rect r) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.6), Radius.circular(r.height * 0.15)), Paint()..color = Palette.cart);
    canvas.drawCircle(Offset(r.left + r.width * 0.25, r.top + r.height * 0.75), r.height * 0.22, Paint()..color = Palette.doorDark);
    canvas.drawCircle(Offset(r.right - r.width * 0.25, r.top + r.height * 0.75), r.height * 0.22, Paint()..color = Palette.doorDark);
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StallView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'A cart behind one of n doors and goats behind the rest, all equally '
      'likely; you pick a door, the host, who knows where the cart is, opens k of '
      'the other doors that hide goats, and you stay or switch to one of the other '
      'unopened doors. Staying wins when the first pick was right, one game in n. '
      'Switching wins when it was wrong, n - 1 games in n, and then lands on the '
      'cart one time in n - 1 - k, since the host opened only goats and left the '
      'cart among fewer doors: (n - 1)/n times 1/(n - 1 - k), which is more than '
      '1/n whenever the host opens a door at all. Every case is counted on the '
      'sham, the cart\'s door and the pick and the host\'s choice and the switch\'s '
      'landing, on all 72 settings of three to ten doors, and the count agrees with '
      'the formula every time.';
  return '$law ${level.note}';
}
