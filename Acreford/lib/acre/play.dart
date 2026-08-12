import 'field.dart';
import 'rules.dart';

/// A fence being walked. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.field, this.walk, this.closed, this.moves, this.before);

  factory Play.of(Field field) =>
      Play._(field, const [], false, 0, null);

  /// A play stood at a closed paddock, for the mark and the tests.
  factory Play.standing(Field field, List<(int, int)> walk) =>
      Play._(field, List.of(walk), true, walk.length + 1, null);

  final Field field;

  /// The posts walked so far, in order.
  final List<(int, int)> walk;

  /// Whether the fence has been closed back to its first post.
  final bool closed;

  /// Walks, closings and unwindings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless field admits it.
  static const gaveUpAt = 21;

  int get twoA => Rules.twiceAcres(walk);

  /// The posts the open fence stands on so far: walked posts
  /// and every post a strung rail runs over.
  int get rimSoFar {
    if (walk.isEmpty) return 0;
    if (closed) return Rules.rimPosts(walk);
    var rim = 1;
    for (var i = 0; i + 1 < walk.length; i++) {
      rim += Rules.railGap(walk[i], walk[i + 1]);
    }
    return rim;
  }

  int get twoAByPick => Rules.twiceAcresByPick(walk);
  int get rim => Rules.rimPosts(walk);
  int get inside => Rules.insidePosts(walk);
  int get midRail => Rules.midRailPosts(walk);

  bool get isDone =>
      closed &&
      Rules.lands(
        walk,
        twoA: field.twoA,
        inside: field.inside,
        midRail: field.midRail,
      );

  bool get gaveUp => !field.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether tapping [post] would do anything at all.
  bool takes((int, int) post) {
    if (isOver) return false;
    if (closed) return false;
    if (walk.isEmpty) return true;
    if (post == walk.first) {
      return walk.length == field.posts &&
          Rules.sound(walk);
    }
    if (walk.contains(post)) return false;
    if (walk.length == field.posts) return false;
    return Rules.chainSound([...walk, post]);
  }

  /// Walks to a post, or closes the fence at the first post.
  Play tapAt((int, int) post) {
    if (!takes(post)) return this;
    if (walk.isNotEmpty && post == walk.first) {
      return Play._(field, walk, true, moves + 1, this);
    }
    return Play._(field, [...walk, post], false, moves + 1, this);
  }

  /// Unwinds the last walk, or opens a closed fence.
  Play get back {
    if (before == null) return this;
    if (closed) {
      return Play._(field, walk, false, moves + 1, this);
    }
    return Play._(
        field, walk.sublist(0, walk.length - 1), false, moves + 1, this);
  }

  /// What the show-me points at: a post to walk, the first post
  /// to close on, or null with [mustUnwind] when the standing
  /// walk reaches no landing paddock.
  ((int, int), bool)? get next {
    if (isOver || !field.winnable) return null;
    if (closed) return null;
    final aim = _completion(walk);
    if (aim == null) return null;
    if (aim.length == walk.length) return (walk.first, true);
    return (aim[walk.length], false);
  }

  /// Whether the standing walk still reaches a landing paddock.
  bool get couldStillLand {
    if (!field.winnable) return false;
    if (closed) return isDone;
    return _completion(walk) != null;
  }

  /// A full landing walk extending [given], or null. When the
  /// walk already lands closed, returns it unchanged.
  List<(int, int)>? _completion(List<(int, int)> given) {
    if (given.length == field.posts) {
      final lands = Rules.sound(given) &&
          Rules.lands(
            given,
            twoA: field.twoA,
            inside: field.inside,
            midRail: field.midRail,
          );
      return lands ? given : null;
    }
    for (final post in Rules.field) {
      if (given.contains(post)) continue;
      if (given.isNotEmpty &&
          !Rules.chainSound([...given, post])) {
        continue;
      }
      final found = _completion([...given, post]);
      if (found != null) return found;
    }
    return null;
  }
}
