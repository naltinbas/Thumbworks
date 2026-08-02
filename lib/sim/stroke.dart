import 'shapes.dart';

/// A line somebody drew, as the points their finger went through.
///
/// Immutable, and thinned as it grows. A finger reports its position sixty or
/// a hundred and twenty times a second, which over a stroke across the screen
/// is several hundred points a millimetre apart — and every one of them is a
/// line the physics has to check the ball against, every step, forever. Most
/// of them say nothing the one before did not.
class Stroke {
  const Stroke(this.points);

  static const empty = Stroke([]);

  final List<Spot> points;

  /// How far the finger must move before a point is worth keeping.
  ///
  /// Small enough that a curve still reads as a curve and large enough that a
  /// stroke down the screen is thirty lines rather than three hundred.
  static const grain = 0.16;

  bool get isEmpty => points.length < 2;

  /// How much chalk this used: its own length.
  double get length {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).length;
    }
    return total;
  }

  /// The straight pieces the physics sees.
  List<Line> get lines => [
        for (var i = 1; i < points.length; i++) Line(points[i - 1], points[i]),
      ];

  /// This stroke with another point on the end, if it is far enough from the
  /// last one to be worth having.
  Stroke to(Spot spot) {
    if (points.isEmpty) return Stroke([spot]);
    if ((spot - points.last).length < grain) return this;
    return Stroke([...points, spot]);
  }

  @override
  String toString() => 'stroke of ${points.length} points, '
      '${length.toStringAsFixed(2)} long';
}

/// Everything drawn so far, and how much chalk is left.
class Drawing {
  const Drawing({required this.strokes, required this.ink});

  factory Drawing.with_(double ink) =>
      Drawing(strokes: const [], ink: ink);

  final List<Stroke> strokes;

  /// How much chalk the level gives.
  final double ink;

  double get used =>
      strokes.fold(0, (total, stroke) => total + stroke.length);

  double get left => ink - used;

  bool get isEmpty => strokes.every((stroke) => stroke.isEmpty);

  List<Line> get lines => [
        for (final stroke in strokes) ...stroke.lines,
      ];

  /// This drawing with a stroke added, cut short if it runs out of chalk.
  ///
  /// Cut rather than refused. A stroke that vanishes when the finger goes one
  /// millimetre too far is a stroke the player has to draw again; a stroke that
  /// stops where the chalk ran out is the same information without the loss.
  Drawing add(Stroke stroke) {
    if (stroke.isEmpty) return this;
    var room = left;
    if (room <= 0) return this;

    final kept = <Spot>[stroke.points.first];
    for (var i = 1; i < stroke.points.length; i++) {
      final step = (stroke.points[i] - stroke.points[i - 1]).length;
      if (step > room) {
        if (room > 0.01) {
          kept.add(
            stroke.points[i - 1] +
                (stroke.points[i] - stroke.points[i - 1]).unit * room,
          );
        }
        room = 0;
        break;
      }
      kept.add(stroke.points[i]);
      room -= step;
    }

    if (kept.length < 2) return this;
    return Drawing(strokes: [...strokes, Stroke(kept)], ink: ink);
  }

  /// This drawing without its last stroke.
  Drawing get back => strokes.isEmpty
      ? this
      : Drawing(strokes: strokes.sublist(0, strokes.length - 1), ink: ink);

  Drawing get cleared => Drawing(strokes: const [], ink: ink);
}
