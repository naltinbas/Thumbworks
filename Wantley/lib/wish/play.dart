import 'rules.dart';
import 'wish.dart';

/// A green being trodden. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.wish, this.rules, this.trodden, this.moves, this.before);

  factory Play.of(Wish wish) => Play._(
      wish,
      Rules(wish.farms),
      List.filled(Rules(wish.farms).pairs.length, false),
      0,
      null);

  /// A play stood at a treading, for the mark and the tests.
  factory Play.standing(Wish wish, List<(int, int)> paths) {
    final rules = Rules(wish.farms);
    final trodden = List.filled(rules.pairs.length, false);
    for (final path in paths) {
      trodden[rules.pairs.indexOf(path)] = true;
    }
    return Play._(wish, rules, trodden, paths.length, null);
  }

  final Wish wish;
  final Rules rules;

  /// One bool per pair: whether its path is trodden.
  final List<bool> trodden;

  /// Treadings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless list admits it.
  static const gaveUpAt = 12;

  List<int> get counts => rules.counts(trodden);

  /// How many paths stand.
  int get paths => trodden.where((tread) => tread).length;

  bool get isDone {
    final walked = counts;
    for (var farm = 0; farm < wish.farms; farm++) {
      if (walked[farm] != wish.wishes[farm]) return false;
    }
    return true;
  }

  bool get gaveUp => !wish.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Treads or lifts the path between one pair of farms.
  Play flipAt(int pair) {
    if (isOver || pair < 0 || pair >= rules.pairs.length) {
      return this;
    }
    final turned = List.of(trodden);
    turned[pair] = !turned[pair];
    return Play._(wish, rules, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pair the show-me points at: a wrong path to lift, or a
  /// missing path of the built landing; null when none lands.
  int? get next {
    if (isOver) return null;
    final aim = rules.build(wish.wishes);
    if (aim == null) return null;
    final wanted = List.filled(rules.pairs.length, false);
    for (final path in aim) {
      wanted[rules.pairs.indexOf(path)] = true;
    }
    for (var pair = 0; pair < rules.pairs.length; pair++) {
      if (trodden[pair] && !wanted[pair]) return pair;
    }
    for (var pair = 0; pair < rules.pairs.length; pair++) {
      if (!trodden[pair] && wanted[pair]) return pair;
    }
    return null;
  }
}
