import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../court/play.dart';
import 'palette.dart';

/// Where the court lies on the board, so the screen and the tests
/// can find every flag.
class Metrics {
  Metrics(this.play, Size room) {
    final side = play.court.side;
    final fit = math.min(room.width, room.height) * 0.86;
    cell = fit / side;
    origin = Offset(
      (room.width - fit) / 2,
      (room.height - fit) / 2,
    );
  }

  final Play play;

  /// The side of one flag.
  late final double cell;

  /// The top-left corner of the court.
  late final Offset origin;

  Rect rectOf(int index) {
    final side = play.court.side;
    final x = index % side;
    final y = index ~/ side;
    return Rect.fromLTWH(
      origin.dx + x * cell,
      origin.dy + y * cell,
      cell,
      cell,
    );
  }

  /// The middle of a flag.
  Offset cellAt(int index) => rectOf(index).center;

  /// The flag under a touch, or null off the court.
  int? under(Offset touch) {
    final side = play.court.side;
    final x = ((touch.dx - origin.dx) / cell).floor();
    final y = ((touch.dy - origin.dy) / cell).floor();
    if (x < 0 || y < 0 || x >= side || y >= side) return null;
    return y * side + x;
  }
}

/// The court itself: flags, the well, the elbows laid, the studs
/// showing brass, and the rings of a pick or a pointer.
class CourtView extends CustomPainter {
  CourtView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// ('lay' or 'lift', the elbow's cells), or null.
  final (String, List<int>)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final rules = play.rules;
    final side = play.court.side;
    final cell = metrics.cell;
    final gap = cell * 0.045;

    // The bare flags.
    for (var index = 0; index < rules.cells; index++) {
      if (index == play.court.well) continue;
      final rect = metrics.rectOf(index).deflate(gap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.08)),
        Paint()..color = Palette.flag,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.08)),
        Paint()
          ..color = Palette.flagRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cell * 0.02),
      );
    }

    // The elbows, one shape apiece: each of its flags filled,
    // then the seams between neighbours in the same elbow painted
    // over so the three read as one stone.
    final tints = tintsFor(play);
    for (var order = 0; order < play.laid.length; order++) {
      final elbow = play.laid[order];
      final tint = Palette.stones[tints[order]];
      final paint = Paint()..color = tint;
      for (final index in elbow) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            metrics.rectOf(index).deflate(gap),
            Radius.circular(cell * 0.12),
          ),
          paint,
        );
      }
      for (final a in elbow) {
        for (final b in elbow) {
          if (b <= a) continue;
          final ax = a % side, ay = a ~/ side;
          final bx = b % side, by = b ~/ side;
          if ((ax - bx).abs() + (ay - by).abs() != 1) continue;
          // Bridge the gap between two side-by-side flags.
          final ra = metrics.rectOf(a).deflate(gap);
          final rb = metrics.rectOf(b).deflate(gap);
          final bridge = Rect.fromLTRB(
            math.min(ra.left, rb.left) + (ax == bx ? cell * 0.14 : 0),
            math.min(ra.top, rb.top) + (ay == by ? cell * 0.14 : 0),
            math.max(ra.right, rb.right) - (ax == bx ? cell * 0.14 : 0),
            math.max(ra.bottom, rb.bottom) - (ay == by ? cell * 0.14 : 0),
          );
          canvas.drawRect(bridge, paint);
        }
      }
    }

    // The studs: brass where bare, dim under an elbow, and never
    // on the four-court, where the count does not bite.
    if (side == 5) {
      for (final stud in rules.studs) {
        if (stud == play.court.well) continue;
        final at = metrics.cellAt(stud);
        final bareStud = play.elbowAt(stud) == null;
        canvas.drawCircle(
          at,
          cell * (bareStud ? 0.13 : 0.07),
          Paint()..color = bareStud ? Palette.stud : Palette.studDim,
        );
        if (bareStud) {
          canvas.drawCircle(
            at,
            cell * 0.2,
            Paint()
              ..color = Palette.stud
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1, cell * 0.03),
          );
        }
      }
    }

    // The well.
    final wellAt = metrics.cellAt(play.court.well);
    canvas.drawCircle(wellAt, cell * 0.36, Paint()..color = Palette.well);
    canvas.drawCircle(
      wellAt,
      cell * 0.36,
      Paint()
        ..color = Palette.wellRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, cell * 0.06),
    );
    canvas.drawCircle(
      wellAt,
      cell * 0.18,
      Paint()
        ..color = Palette.wellRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.025),
    );

    // The flags picked toward an elbow.
    for (final index in play.pending) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          metrics.rectOf(index).deflate(gap + cell * 0.04),
          Radius.circular(cell * 0.1),
        ),
        Paint()
          ..color = Palette.picked
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, cell * 0.06),
      );
    }

    // The pointer's elbow.
    final aim = pointing;
    if (aim != null) {
      for (final index in aim.$2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            metrics.rectOf(index).deflate(gap + cell * 0.1),
            Radius.circular(cell * 0.1),
          ),
          Paint()
            ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, cell * 0.06),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CourtView old) =>
      old.play != play || old.pointing != pointing;
}

/// A tint for every elbow laid, in laying order: the first of the
/// four not already worn by an elbow touching it, so neighbours
/// read apart, and the next in turn when all four are taken.
List<int> tintsFor(Play play) {
  final side = play.court.side;
  final tints = <int>[];
  for (var order = 0; order < play.laid.length; order++) {
    final elbow = play.laid[order];
    final worn = <int>{};
    for (var other = 0; other < order; other++) {
      var touches = false;
      for (final a in elbow) {
        for (final b in play.laid[other]) {
          final dx = (a % side - b % side).abs();
          final dy = (a ~/ side - b ~/ side).abs();
          if (dx + dy == 1) touches = true;
        }
      }
      if (touches) worn.add(tints[other]);
    }
    var tint = order % Palette.stones.length;
    for (var try_ = 0; try_ < Palette.stones.length; try_++) {
      if (!worn.contains(try_)) {
        tint = try_;
        break;
      }
    }
    tints.add(tint);
  }
  return tints;
}

/// The why, spoken for a court as it stands.
String whyWords(Play play) {
  final court = play.court;
  final note = court.note == null ? '' : ' ${court.note}';
  if (!court.winnable) {
    return 'Count the brass: nine studs, one to every two-by-two '
        'block of the court. An elbow is a two-by-two block less a '
        'corner, so it covers one stud at most, and eight elbows '
        'cover eight at most. This well is no stud, so all nine '
        'want covering, and one stays bare whatever you lay. The '
        'sweep tried every laying there is and found no '
        'paving.$note';
  }
  final second = court.side == 4
      ? 'Golomb\'s quartering builds a paving with no searching, '
          'one elbow at the crossing and one in each quarter, and '
          'it lays the sweep\'s own paving, elbow for elbow.'
      : 'the nine studs say where a well may sit at all, one stud '
          'to a block and one block to an elbow, and the sweep '
          'lands exactly there and nowhere else.';
  return 'The pavings are counted by the sweep, first bare flag '
      'first, and held to a second voice: $second '
      '${court.ways} paving${court.ways == 1 ? '' : 's'} '
      'land${court.ways == 1 ? 's' : ''} this court.$note';
}
