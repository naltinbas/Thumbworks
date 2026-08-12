import 'pitch.dart';
import 'rules.dart';

/// A wall being raised. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.pitch, this.courses, this.before);

  factory Play.of(Pitch pitch) => Play._(pitch, const [], null);

  final Pitch pitch;

  /// The courses laid, bottom first.
  final List<int> courses;

  final Play? before;

  bool get isDone => courses.length >= pitch.height;

  /// The doubled run laying [kind] would make, or null when it
  /// stands sound.
  (int, int)? doubledBy(int kind) =>
      Rules.doubledRun([...courses, kind]);

  bool mayLay(int kind) => !isDone && doubledBy(kind) == null;

  /// One more course.
  Play lay(int kind) {
    if (!mayLay(kind)) return this;
    return Play._(pitch, [...courses, kind], this);
  }

  Play get back => before ?? this;

  /// Whether the asked height is still in reach from here.
  bool get climbs =>
      Rules.canClimb(courses, pitch.kinds, pitch.height);

  /// A kind that keeps the height in reach, or null.
  int? get next => isDone
      ? null
      : Rules.nextKind(courses, pitch.kinds, pitch.height);

  /// Whether the wall is penned in: sound, unfinished, and no
  /// course of any kind stands.
  bool get pennedIn {
    if (isDone) return false;
    for (var kind = 0; kind < pitch.kinds; kind++) {
      if (mayLay(kind)) return false;
    }
    return true;
  }
}
