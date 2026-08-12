import 'rules.dart';
import 'setting.dart';

/// A marsh being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.marsh, this.posts, this.moves, this.before);

  factory Play.of(Setting marsh) => Play._(marsh, const [], 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Setting marsh, List<(int, int)> posts) =>
      Play._(marsh, List.of(posts), posts.length, null);

  final Setting marsh;

  /// The posts as they stand, in the order set.
  final List<(int, int)> posts;

  /// Posts set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless marsh admits it.
  static const gaveUpAt = 16;

  List<List<(int, int)>> get frames => Rules.frames(posts);

  List<((int, int), (int, int), (int, int))> get lined =>
      Rules.shared(posts);

  bool get allSet => posts.length == marsh.posts;

  bool get isDone =>
      allSet && lined.isEmpty && frames.length == marsh.asked;

  bool get gaveUp => !marsh.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets a post on an empty crossing, or lifts the one there.
  Play tapAt((int, int) spot) {
    if (isOver) return this;
    if (posts.contains(spot)) {
      return Play._(marsh,
          [for (final p in posts) if (p != spot) p], moves + 1, this);
    }
    if (allSet) return this;
    return Play._(marsh, [...posts, spot], moves + 1, this);
  }

  Play get back => before ?? this;

  /// The next touch towards a setting that lands the asking:
  /// lift a stray post first, then set a missing one. Null when
  /// nothing lands it.
  (int, int)? get next {
    final aim = Rules.setting(marsh.posts, marsh.asked);
    if (aim == null || isDone) return null;
    for (final post in posts) {
      if (!aim.contains(post)) return post;
    }
    for (final spot in aim) {
      if (!posts.contains(spot)) return spot;
    }
    return null;
  }
}
