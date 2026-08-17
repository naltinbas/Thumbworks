import 'level.dart';
import 'levels.dart';
import 'root3.dart';
import 'rules.dart';

/// One go at an ask: where the posts stand, the posts moved, and the go
/// before, so a move can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.posts,
    required this.lifted,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : posts = Rules.opening,
        lifted = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a field, no moves counted: what the mark draws.
  Play.standing(this.level, this.posts, {this.lifted})
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Where the three posts stand.
  final List<(int, int)> posts;

  /// The post in hand, waiting for a peg, or null.
  final int? lifted;

  /// The posts moved.
  final int moves;

  /// The fields tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The moves a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The fields a hopeless ask lets the player stand before the sham
  /// admits it.
  static const enough = 4;

  /// The three rick markers, raised outward.
  List<(Root3, Root3)> get markers => Rules.markers(posts);

  /// The three corners of the ricks themselves.
  List<(Root3, Root3)> get rickCorners => Rules.rickCorners(posts);

  /// The three sides of the marker triangle, squared.
  List<Root3> get markerSides => Rules.markerSides(posts);

  /// Whether the markers are evenly spread, which they always are.
  bool get even => Rules.evenByLength(posts);

  int get halfAcres => Rules.halfAcres(posts);

  bool get squareCorner => Rules.squareCorner(posts);

  Play _to(List<(int, int)> to) {
    final at = Rules.tellPosts(to);
    return Play._(
      level: level,
      posts: to,
      lifted: null,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Lifts a post, or puts the one in hand down on a peg.
  Play tap((int, int) peg) {
    if (isOver || !Rules.onGreen(peg)) return this;
    final held = lifted;
    if (held == null) {
      for (var i = 0; i < 3; i++) {
        if (posts[i] == peg) {
          return Play._(
            level: level,
            posts: posts,
            lifted: i,
            moves: moves,
            seen: seen,
            before: before,
          );
        }
      }
      return this;
    }
    if (posts[held] == peg) {
      return Play._(
        level: level,
        posts: posts,
        lifted: null,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    final to = [
      for (var i = 0; i < 3; i++) if (i == held) peg else posts[i],
    ];
    if (!Rules.isField(to)) return this;
    return _to(to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(posts);

  /// A hopeless ask, admitted: [enough] fields tried, or [gaveUpAt]
  /// posts moved.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every field that lands the ask, worked out once per ask.
  static final Map<String, List<List<(int, int)>>> _winners = {};

  static List<List<(int, int)>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final field in Rules.fields())
            if (level.meets(field)) field,
        ];
      });

  /// The nearest field that lands the ask, and how many posts away it
  /// is.
  (List<(int, int)>, int)? get nearest {
    List<(int, int)>? best;
    var away = -1;
    for (final win in winners(level)) {
      final n = Rules.moves(posts, win);
      if (away < 0 || n < away) {
        away = n;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the post to lift and the peg to put it on;
  /// null when there is nothing to point at.
  (int, (int, int))? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // Take the reading of the nearest field that moves the fewest
    // posts, and name the first post that has to shift.
    for (final order in [
      [0, 1, 2],
      [0, 2, 1],
      [1, 0, 2],
      [1, 2, 0],
      [2, 0, 1],
      [2, 1, 0],
    ]) {
      var n = 0;
      for (var i = 0; i < 3; i++) {
        if (posts[i] != near.$1[order[i]]) n++;
      }
      if (n != near.$2) continue;
      for (var i = 0; i < 3; i++) {
        if (posts[i] != near.$1[order[i]]) return (i, near.$1[order[i]]);
      }
    }
    return null;
  }

  /// The pointer's words, given what the hand is holding.
  String pointed((int, (int, int)) aim) {
    if (lifted == null) return 'Lift post ${aim.$1 + 1}.';
    if (lifted == aim.$1) {
      return 'Stand it on the peg at ${aim.$2.$1}, ${aim.$2.$2}.';
    }
    return 'Put post ${lifted! + 1} back where it was.';
  }
}

/// Why the markers are always evenly spread: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Three posts on the green make a field. On each of its three sides a '
      'hayrick is raised, an even triangle built outward, and a marker goes '
      'at the middle of each rick.\n\n'
      'However the posts stand, the three markers make an even triangle of '
      'their own. Not nearly even: exactly. Rutherford printed it in The '
      'Ladies\' Diary in 1825, and it has carried Napoleon\'s name ever '
      'since.\n\n'
      'Raising an even triangle on a side means turning that side by sixty '
      'degrees, and the sine of sixty is half the root of three. So every '
      'marker sits at a place of the form a plus b roots of three, with a and '
      'b exact fractions, and the sham works in those and never in decimals. '
      'Two such places are the same only when both halves match, since the '
      'root of three is not a fraction, so equal is equal and not nearly.\n\n'
      'The sham settles it twice. It measures the three gaps between the '
      'markers and compares them, and it also turns one marker sixty degrees '
      'about another and sees whether it lands on the third, which measures '
      'nothing. There is a third fact in the ledger: raise the ricks inward '
      'instead and those markers make an even triangle too, and the two '
      'triangles\' areas, signed, add up to the field\'s own. The roots of '
      'three cancel and a whole number is left.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every field the green holds, '
      'measured before the sham was built.';
}
