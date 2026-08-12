import 'package:flutter/material.dart';

import '../wall/play.dart';
import 'palette.dart';

/// Where every course lies, shared by the painter and the tests.
class Metrics {
  Metrics(this.play, Size room) {
    left = room.width * 0.1;
    wide = room.width * 0.8;
    courseHigh = (room.height * 0.86) / (play.pitch.height + 1);
    ground = room.height * 0.94;
  }

  final Play play;

  late final double left;
  late final double wide;
  late final double courseHigh;
  late final double ground;

  /// The band of one course, counted from the ground up.
  Rect courseRect(int at) => Rect.fromLTWH(
        left,
        ground - courseHigh * (at + 1),
        wide,
        courseHigh,
      );
}

/// The wall, drawn.
class WallView extends CustomPainter {
  WallView({
    required this.play,
    this.doubled,
    required this.labels,
  });

  final Play play;

  /// A doubled run being shown: where it starts and how long each
  /// half runs, or null.
  final (int, int)? doubled;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The ground.
    canvas.drawLine(
      Offset(metrics.left * 0.4, metrics.ground),
      Offset(size.width - metrics.left * 0.4, metrics.ground),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 2.6,
    );

    // The asked height.
    final roof = metrics.courseRect(play.pitch.height - 1);
    canvas.drawLine(
      Offset(metrics.left * 0.4, roof.top),
      Offset(size.width - metrics.left * 0.4, roof.top),
      Paint()
        ..color = Palette.heightMark.withValues(alpha: 0.55)
        ..strokeWidth = 1.6,
    );

    for (var at = 0; at < play.courses.length; at++) {
      _course(canvas, metrics, at);
    }
  }

  void _course(Canvas canvas, Metrics metrics, int at) {
    final band = metrics.courseRect(at).deflate(1.4);
    final kind = play.courses[at];
    final hot = doubled != null &&
        at >= doubled!.$1 &&
        at < doubled!.$1 + 2 * doubled!.$2;

    // A course is a run of stones, offset every other course like
    // real walling.
    final stones = 4 + (at.isEven ? 0 : 1);
    final stoneWide = band.width / stones;
    for (var stone = 0; stone < stones; stone++) {
      final block = Rect.fromLTWH(
        band.left + stone * stoneWide,
        band.top,
        stoneWide,
        band.height,
      ).deflate(1.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(4)),
        Paint()..color = Palette.kinds[kind],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(4)),
        Paint()
          ..color = hot ? Palette.doubled : Palette.stoneRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = hot ? 2.4 : 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(WallView old) =>
      old.play != play || old.doubled != doubled;
}

/// The words the why speaks, from the pitch at hand.
String whyWords(Play play) {
  final pitch = play.pitch;
  final note = pitch.note == null ? '' : ' ${pitch.note}';
  if (!pitch.winnable) {
    return 'No run of courses may be laid twice over, and with two '
        'kinds of stone that rule closes the fell: the sweep lays '
        'all sixteen walls of four courses and every one carries a '
        'doubled run. Three courses is the roof, two ways, and the '
        'fourth never comes.$note';
  }
  return 'No run of courses may be laid twice over: one course '
      'doubled, or a block of five doubled, all the same. The '
      'sweep lays every wall there is and counts what stands at '
      'the asked height, and the walk grows the standing wall '
      'every way to know whether the height is still in reach '
      'before a course is ever refused.$note';
}
