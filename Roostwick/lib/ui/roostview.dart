import 'dart:math';

import 'package:flutter/material.dart';

import '../roost/play.dart';
import '../roost/rules.dart';
import 'palette.dart';

/// Where the six hollows sit in a board of a given size, and where each
/// bird sits inside its hollow.
///
/// The hollows are cut into the bank in two rows of three, A B C over
/// D E F, and they never move. Only the birds do.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 24.0;
    final room = Size(size.width - 16, size.height - words - 16);
    cellWidth = room.width / 3;
    // A tall board would fling the two rows to opposite ends of it, so
    // the rows are kept within reach of each other and the bank sits in
    // the middle of whatever room there is.
    cellHeight = min(room.height / 2, cellWidth * 1.45);
    left = 8;
    top = 8 + (room.height - cellHeight * 2) / 2;
    radius = min(cellWidth, cellHeight) * (bare ? 0.44 : 0.42);
    gap = radius * 0.55;
    bird = radius * (bare ? 0.30 : 0.21);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double cellWidth, cellHeight, left, top, radius, gap, bird;

  /// Whether there is room for words under the board.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  /// The middle of a hollow.
  Offset hollow(int h) => Offset(
        left + (h % 3 + 0.5) * cellWidth,
        top + (h ~/ 3 + 0.5) * cellHeight,
      );

  /// How the birds in one hollow are laid out: the count in each row.
  static List<int> rowsFor(int count) =>
      count <= 1 ? [count] : [(count + 1) ~/ 2, count ~/ 2];

  /// Where the [which]th bird of a hollow holding [count] of them sits.
  Offset perch(int h, int which, int count) {
    final rows = rowsFor(count);
    var row = 0, before = 0;
    while (row < rows.length - 1 && which >= before + rows[row]) {
      before += rows[row];
      row++;
    }
    final inRow = which - before;
    final middle = hollow(h);
    return Offset(
      middle.dx + (inRow - (rows[row] - 1) / 2) * gap,
      middle.dy + (row - (rows.length - 1) / 2) * gap,
    );
  }

  /// Where every bird sits, bird by bird.
  List<Offset> get perches {
    final spots = List.filled(play.birds.length, Offset.zero);
    final crowds = play.crowds;
    for (var h = 0; h < Rules.hollows; h++) {
      final here = crowds[h];
      for (var k = 0; k < here.length; k++) {
        spots[here[k]] = perch(h, k, here.length);
      }
    }
    return spots;
  }

  /// The bird a tap means, or null when it lands nowhere near one.
  int? birdNear(Offset where) {
    final spots = perches;
    int? best;
    var away = radius * 0.45;
    for (var i = 0; i < spots.length; i++) {
      final d = (spots[i] - where).distance;
      if (d < away) {
        away = d;
        best = i;
      }
    }
    return best;
  }
}

/// The bank, its six hollows, and the birds tethered between them.
class RoostView extends CustomPainter {
  const RoostView({
    required this.play,
    this.pointing,
    this.showWhyNot = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The bird the show-me points at, or null.
  final int? pointing;

  /// Whether to ring the hollows that hold more birds than they can
  /// seat, which is the reason an ask cannot be settled.
  final bool showWhyNot;

  final TextStyle labels;

  /// Whether to draw the wood alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final crowds = play.crowds;
    final spots = m.perches;
    final marked = showWhyNot ? play.overfull : const <int>[];

    // The hollows, cut into the bank.
    for (var h = 0; h < Rules.hollows; h++) {
      final middle = m.hollow(h);
      final here = crowds[h].length;
      canvas.drawCircle(middle, m.radius, Paint()..color = Palette.hollow);
      canvas.drawCircle(
        middle,
        m.radius,
        Paint()
          ..color = here > 1
              ? Palette.crowd
              : here == 1
                  ? Palette.alone
                  : Palette.rim
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : (here > 1 ? 2.4 : 1.6),
      );
      if (marked.contains(h)) {
        canvas.drawCircle(
          middle,
          m.radius + (bare ? 5 : 4),
          Paint()
            ..color = Palette.crowd
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
      if (!bare) {
        // Inside the rim rather than above it: on a small phone the two
        // rows come close enough that a label above the lower one would
        // sit on the hollow overhead.
        _word(canvas, Rules.letter(h), middle - Offset(0, m.radius * 0.72),
            Palette.inkDim, size, m.radius * 0.26);
      }
    }

    // Each bird's tether, drawn from where it sits to the hollow it
    // would fly to. It is the bird's own thread, not a line between two
    // dots.
    for (var i = 0; i < play.birds.length; i++) {
      final to = m.hollow(play.across(i));
      final from = spots[i];
      final along = (to - from);
      final length = along.distance;
      if (length < 1) continue;
      final stop = to - along / length * m.radius;
      // The tethers are bowed rather than straight, alternately one way
      // and the other, so that two birds strung between the same pair of
      // hollows read as two threads and a thread bound for a far hollow
      // does not lie across the ones between.
      final aside = Offset(-along.dy, along.dx) / length * length * 0.12;
      final bow = (from + stop) / 2 + (i.isEven ? aside : -aside);
      canvas.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(bow.dx, bow.dy, stop.dx, stop.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = (pointing == i ? Palette.shown : Palette.tether)
              .withValues(alpha: bare ? 1 : (pointing == i ? 0.9 : 0.45))
          ..strokeWidth = bare ? 4 : (pointing == i ? 2.2 : 1.1),
      );
    }

    // The birds.
    for (var i = 0; i < play.birds.length; i++) {
      final crowdedHere = crowds[play.at[i]].length > 1;
      canvas.drawCircle(
        spots[i],
        m.bird,
        Paint()..color = crowdedHere ? Palette.crowd : Palette.bird,
      );
      if (!bare) {
        _word(canvas, '${i + 1}', spots[i], Palette.night, size,
            m.bird * 1.15);
      }
      if (!bare && pointing == i) {
        canvas.drawCircle(
          spots[i],
          m.bird * 1.9,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (bare || !m.roomy) return;
    // The patches, which are what the rule is read off: follow the
    // tethers, and count the hollows and the birds in each lot.
    final patches = [
      for (final patch in Rules.patchSizes(play.birds))
        if (patch.$2 > 0) '${patch.$1} hollows, ${patch.$2} birds',
    ];
    _word(
      canvas,
      'patches: ${patches.join('   ')}',
      Offset(size.width / 2, size.height - 10),
      Palette.inkDim,
      size,
      10,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RoostView old) =>
      old.play.pick != play.pick ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWhyNot != showWhyNot ||
      old.bare != bare;
}
