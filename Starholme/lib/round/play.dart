import 'rules.dart';
import 'tour.dart';

/// A round being walked. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.tour, this.walk, this.closed, this.moves, this.before);

  factory Play.of(Tour tour) =>
      Play._(tour, const [], false, 0, null);

  /// A play stood at a closed round, for the mark and the tests.
  factory Play.standing(Tour tour, List<int> walk) =>
      Play._(tour, List.of(walk), true, walk.length + 1, null);

  final Tour tour;

  /// The posts walked so far, in order.
  final List<int> walk;

  /// Whether the round has closed back on its first post.
  final bool closed;

  /// Walks, closings and unwindings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless tour admits it.
  static const gaveUpAt = 24;

  bool get isDone =>
      closed && walk.length == tour.posts && Rules.sound(walk);

  bool get gaveUp => !tour.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether tapping [post] would do anything at all.
  bool takes(int post) {
    if (isOver || closed || post < 0 || post > 9) return false;
    if (walk.isEmpty) return true;
    if (post == walk.first) {
      return walk.length == tour.posts && Rules.sound(walk);
    }
    if (walk.contains(post)) return false;
    if (walk.length == tour.posts) return false;
    return Rules.beside(walk.last, post);
  }

  /// Walks to a post, or closes the round at the first post.
  Play tapAt(int post) {
    if (!takes(post)) return this;
    if (walk.isNotEmpty && post == walk.first) {
      return Play._(tour, walk, true, moves + 1, this);
    }
    return Play._(tour, [...walk, post], false, moves + 1, this);
  }

  Play get back {
    if (before == null) return this;
    if (closed) return Play._(tour, walk, false, moves + 1, this);
    return Play._(
        tour, walk.sublist(0, walk.length - 1), false, moves + 1, this);
  }

  /// The post the show-me points at: the next step of a round
  /// extending the standing walk, the first post to close on,
  /// or null when nothing extends.
  int? get next {
    if (isOver || closed || !tour.winnable) return null;
    List<int>? bestAim;
    Rules.rounds(tour.posts, (round) {
      if (bestAim != null) return;
      // The walk must sit inside the round as a run, either way
      // along it, starting anywhere.
      final doubled = [...round, ...round];
      for (var spin = 0; spin < round.length; spin++) {
        for (final flip in [false, true]) {
          final laid = [
            for (var at = 0; at < round.length; at++)
              flip
                  ? doubled[spin + round.length - at]
                  : doubled[spin + at],
          ];
          var fits = walk.length <= laid.length;
          for (var at = 0; fits && at < walk.length; at++) {
            if (laid[at] != walk[at]) fits = false;
          }
          if (fits) {
            bestAim = laid;
            return;
          }
        }
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    if (walk.length == tour.posts) return walk.first;
    if (walk.isEmpty) return aim.first;
    return aim[walk.length];
  }
}
