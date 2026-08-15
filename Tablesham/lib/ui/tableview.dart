import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../table/play.dart';
import 'palette.dart';

/// Where everyone sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.42);
    ring = math.min(room.width, room.height * 0.84) * 0.36;
    seat = ring * (play.party.couples > 4 ? 0.17 : 0.2);
    benchY = room.height * 0.88;
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double seat;
  late final double benchY;

  /// A wife's seat: wife w at angle for place 2w.
  Offset wifeAt(int wife) => _place(2 * wife);

  /// A gap's chair: gap g at angle for place 2g+1.
  Offset gapAt(int gap) => _place(2 * gap + 1);

  Offset _place(int spot) {
    final places = play.party.couples * 2;
    final turn = -math.pi / 2 + 2 * math.pi * spot / places;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// A benched husband's spot.
  Offset benchAt(int order) {
    final held = play.bench;
    final wide = held.length * seat * 2.6;
    final left = middle.dx - wide / 2 + seat * 1.3;
    return Offset(left + order * seat * 2.6, benchY);
  }

  /// What lies under a touch: ('gap', index), ('bench',
  /// husband), or null.
  (String, int)? under(Offset touch) {
    for (var gap = 0; gap < play.party.couples; gap++) {
      if ((gapAt(gap) - touch).distance <= seat * 1.3) {
        return ('gap', gap);
      }
    }
    final held = play.bench;
    for (var order = 0; order < held.length; order++) {
      if ((benchAt(order) - touch).distance <= seat * 1.3) {
        return ('bench', held[order]);
      }
    }
    return null;
  }
}

/// The table, drawn: wives seated, husbands in their gaps or
/// on the bench, quarrels rimmed rust.
class TableView extends CustomPainter {
  TableView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The (gap, husband) the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final seat = metrics.seat;
    final sore = play.quarrels.toSet();

    // The table itself.
    canvas.drawCircle(metrics.middle, metrics.ring * 0.62,
        Paint()..color = Palette.table);
    canvas.drawCircle(
      metrics.middle,
      metrics.ring * 0.62,
      Paint()
        ..color = Palette.tableRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // The wives, each wearing her number.
    for (var wife = 0; wife < play.party.couples; wife++) {
      final at = metrics.wifeAt(wife);
      canvas.drawCircle(at, seat, Paint()..color = Palette.wife);
      _number(canvas, '${wife + 1}', at, seat);
    }

    // The gaps: chairs, sitters, the held host rimmed.
    for (var gap = 0; gap < play.party.couples; gap++) {
      final at = metrics.gapAt(gap);
      final sitter = play.seated[gap];
      if (sitter == null) {
        canvas.drawCircle(
          at,
          seat * 0.9,
          Paint()
            ..color = Palette.chair
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      } else {
        canvas.drawCircle(
            at, seat, Paint()..color = Palette.husband);
        _number(canvas, '${sitter + 1}', at, seat);
        final heldFast = play.party.given != null &&
            play.party.given!.$1 == gap;
        if (heldFast) {
          canvas.drawCircle(
            at,
            seat * 1.24,
            Paint()
              ..color = Palette.held
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0,
          );
        }
        if (sore.contains(gap)) {
          canvas.drawCircle(
            at,
            seat * 1.24,
            Paint()
              ..color = Palette.quarrel
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.6,
          );
        }
      }
      final aim = pointing;
      if (aim != null && aim.$1 == gap) {
        canvas.drawCircle(
          at,
          seat * 1.45,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The bench.
    final held = play.bench;
    for (var order = 0; order < held.length; order++) {
      final at = metrics.benchAt(order);
      final husband = held[order];
      canvas.drawCircle(at, seat, Paint()..color = Palette.husband);
      _number(canvas, '${husband + 1}', at, seat);
      if (play.picked == husband) {
        canvas.drawCircle(
          at,
          seat * 1.3,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
      final aim = pointing;
      if (aim != null && aim.$2 == husband && play.bench.contains(husband)) {
        canvas.drawCircle(
          at,
          seat * 1.45,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
    }
    if (held.isNotEmpty) {
      final word = TextPainter(
        text: TextSpan(
          text: 'the bench',
          style: labels.copyWith(
              color: Palette.inkDim, fontSize: seat * 0.6),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      word.paint(
          canvas,
          Offset(size.width / 2 - word.width / 2,
              metrics.benchY + seat * 1.5));
    }
  }

  void _number(Canvas canvas, String words, Offset at, double seat) {
    final wear = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
          color: Palette.night,
          fontSize: seat * 0.9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    wear.paint(canvas, at - Offset(wear.width / 2, wear.height / 2));
  }

  @override
  bool shouldRepaint(TableView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the party at hand.
String whyWords(Play play) {
  final party = play.party;
  final note = party.note == null ? '' : ' ${party.note}';
  if (!party.winnable) {
    return 'Look at any husband\'s chair: a circle of four seats '
        'alternates, so his two neighbours are the two wives, '
        'both of them, and one of the two is his own. There is '
        'nowhere else to sit and nobody else to sit by. The '
        'sweep seated both arrangements of two and both '
        'quarrelled.$note';
  }
  return 'The seatings are counted two ways that share nothing: '
      'the sweep sits every husband every way and reads the '
      'neighbours off the circle, and Touchard\'s arithmetic '
      'lands the same count with no searching, falls and rises '
      'over the couples parted. The two agree at every size '
      'shipped. ${party.ways} seating${party.ways == 1 ? '' : 's'} '
      'land${party.ways == 1 ? 's' : ''} this party.$note';
}
