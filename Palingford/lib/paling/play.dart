import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: how the fence stands, which paling is in hand, the
/// moves made, and the go before, so a move can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.fence,
    required this.held,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : fence = Rules.opening,
        held = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A fence standing as given and no moves counted: what the mark draws.
  const Play.built(this.level, this.fence)
      : held = null,
        moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Every paling in the order it stands along the fence, counting the
  /// one in hand as still at its old place.
  final List<int> fence;

  /// The place of the paling the hand has hold of, or null.
  final int? held;

  final int moves;

  /// The fences tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The moves a hopeless ask runs to before the fence admits it.
  static const gaveUpAt = 16;

  /// The fences a hopeless ask lets the player try before it admits it.
  static const enough = 6;

  /// The palings still in the ground, which is all of them unless one is in
  /// hand.
  List<int> get standing =>
      held == null ? fence : ([...fence]..removeAt(held!));

  /// The height of the paling in hand, or null.
  int? get inHand => held == null ? null : fence[held!];

  String get mark => '${fence.join('-')}/$held';

  int get climb => Rules.longestClimb(standing);

  int get drop => Rules.longestDrop(standing);

  /// The tag on each standing paling: its longest climb and longest drop.
  List<(int, int)> get tags {
    final up = Rules.climbs(standing);
    final down = Rules.drops(standing);
    return [for (var i = 0; i < up.length; i++) (up[i], down[i])];
  }

  List<int> get climbLine => Rules.climbLine(standing);

  List<int> get dropLine => Rules.dropLine(standing);

  /// Takes hold of a paling, or lets go of the one already held.
  Play take(int place) {
    if (isOver || place < 0 || place >= Rules.palings) return this;
    if (held != null) return this;
    return Play._(
      level: level,
      fence: fence,
      held: place,
      moves: moves,
      seen: seen,
      before: before,
    );
  }

  /// Slides the paling in hand into a gap. Sliding it back where it came
  /// from is no move at all.
  Play slide(int gap) {
    final hand = held;
    if (isOver || hand == null) return this;
    if (gap < 0 || gap >= Rules.palings) return this;
    if (gap == hand) {
      return Play._(
        level: level,
        fence: fence,
        held: null,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    final to = Rules.lift(fence, hand, gap);
    return Play._(
      level: level,
      fence: to,
      held: null,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, to.join('-')} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => held == null && level.winnable && level.meets(fence);

  /// A hopeless ask, admitted: [enough] fences tried, or [gaveUpAt] moves.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the paling to lift and the gap to slide it
  /// into. Null when there is nothing to point at.
  ///
  /// It walks towards the ask's own fence, which is as near the opening as
  /// any fence that lands the ask, so from the start it costs the fewest
  /// moves there are.
  (int, int)? get next {
    if (isOver || level.aim.isEmpty) return null;
    final away = Rules.between(fence, level.aim);
    if (away == 0) return null;
    final hand = held;
    if (hand != null) {
      for (var gap = 0; gap < Rules.palings; gap++) {
        if (Rules.between(Rules.lift(fence, hand, gap), level.aim) < away) {
          return (hand, gap);
        }
      }
      // This one was standing where it belongs. Put it back.
      return (hand, hand);
    }
    for (var from = 0; from < Rules.palings; from++) {
      for (var gap = 0; gap < Rules.palings; gap++) {
        if (Rules.between(Rules.lift(fence, from, gap), level.aim) < away) {
          return (from, gap);
        }
      }
    }
    return null;
  }

  /// The pointer's words.
  String pointed((int, int) aim) {
    if (held == null) {
      return 'Lift the paling at place ${aim.$1 + 1}, the one ${fence[aim.$1]} '
          'tall.';
    }
    if (held == aim.$1) {
      return aim.$1 == aim.$2
          ? 'That one was already where it belongs. Slide it back into gap '
              '${aim.$2 + 1}.'
          : 'Now slide it into gap ${aim.$2 + 1}.';
    }
    return 'Put the one in hand down first, then lift place ${aim.$1 + 1}.';
  }
}

/// Why a fence of ten cannot hold both runs under four: the words behind the
/// Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Ten palings, no two the same height. A climb is any palings read '
      'left to right, each taller than the one before, and they do not have '
      'to be neighbours. A drop is the same going downhill.\n\n'
      'Hang a tag on every paling. On the front of the tag write the longest '
      'climb that ends at that paling, and on the back the longest drop that '
      'ends there. Now take any two palings and ask whether their tags could '
      'match. The taller of the two stands either to the right of the '
      'shorter, and then its climb is at least one longer, or to the left, '
      'and then the shorter one\'s drop is at least one longer. Either way '
      'the two tags differ. So all ten tags are different, and that is a '
      'thing you can check with your thumb.\n\n'
      'Tags with both numbers three or under come to nine: three fronts by '
      'three backs. Ten palings need ten different tags. So some paling '
      'carries a four, which is to say the fence holds a climb of four or a '
      'drop of four, whatever you do with it. That is the theorem of Erdos '
      'and Szekeres.\n\n'
      'The fence settles it twice over. It sweeps all 3,628,800 orders of '
      'ten palings and reads the two longest runs off each. It also counts '
      'the orders a second way, from shapes rather than fences: Robinson and '
      'Schensted matched every order with a shape whose top row is the '
      'longest climb and whose depth is the longest drop, and the hook '
      'length formula says how many ways a shape can be filled in. A shape '
      'stands for as many orders as it has fillings multiplied by '
      'themselves. No shape of ten fits in a box three wide and three deep, '
      'because such a box holds nine. The two ways of counting agree on all one hundred pairs '
      'of limits.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
