import 'hall.dart';
import 'rules.dart';

/// A watch being posted. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.hall, this.wards, this.before);

  factory Play.of(Hall hall) => Play._(hall, const [], null);

  final Hall hall;

  /// The corners warded, in the order they were posted.
  final List<int> wards;

  final Play? before;

  /// The flags the watch fails to light.
  List<(int, int)> get unlit => Rules.unlit(hall.corners, wards);

  bool get isDone => wards.length <= hall.asked && unlit.isEmpty;

  /// Whether every allowed ward is posted and the floor stays part
  /// dark. On a winnable hall the watch lifts and tries again; on
  /// the hopeless one, one full watch is demonstration enough.
  bool get short =>
      wards.length >= hall.asked && unlit.isNotEmpty;

  bool get isOver => isDone || (short && !hall.winnable);

  bool mayPost(int corner) =>
      !isOver &&
      wards.length < hall.asked &&
      !wards.contains(corner);

  /// Post a ward at a corner.
  Play post(int corner) {
    if (!mayPost(corner)) return this;
    return Play._(hall, [...wards, corner], this);
  }

  /// Stand a ward down.
  Play lift(int corner) {
    if (!wards.contains(corner)) return this;
    return Play._(
      hall,
      [
        for (final ward in wards)
          if (ward != corner) ward,
      ],
      this,
    );
  }

  Play get back => before ?? this;

  /// A full watch within the asking that grows from the posted
  /// wards, swept; null when none does.
  List<int>? get finished {
    if (Rules.unlit(hall.corners, wards).isEmpty) {
      return List.of(wards);
    }
    if (wards.length >= hall.asked) return null;
    for (var corner = 0; corner < hall.corners.length; corner++) {
      if (wards.contains(corner)) continue;
      final grown = Play._(hall, [...wards, corner], null).finished;
      if (grown != null) return grown;
    }
    return null;
  }

  /// The next corner of that watch, or null.
  int? nextOf(List<int> finished) {
    for (final corner in finished) {
      if (!wards.contains(corner)) return corner;
    }
    return null;
  }
}
