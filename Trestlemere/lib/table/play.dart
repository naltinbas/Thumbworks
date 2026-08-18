import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which table each guest is at, the moves made, and
/// the go before, so a move can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.seats,
    required this.moves,
    required this.seen,
    required this.before,
  });

  /// Every guest at the one trestle, which is where each ask opens.
  Play.of(this.level)
      : seats = const [0, 0, 0, 0, 0, 0],
        moves = 0,
        seen = const {},
        before = null;

  /// A go with the guests seated and no moves counted: what the mark
  /// draws.
  const Play.seated(this.level, this.seats)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The table each guest is at. Tables have no names, so two seatings
  /// that differ only in which trestle is which are the same seating.
  final List<int> seats;

  final int moves;

  /// The seatings tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The moves a hopeless ask runs to before the supper admits it.
  static const gaveUpAt = 16;

  /// The seatings a hopeless ask lets the player try before the supper
  /// admits it.
  static const enough = 6;

  /// How many trestles are laid out to move guests between. One more
  /// than the guests would be useless, since six guests never need more
  /// than six tables.
  static const trestles = Rules.guests;

  /// The seating as tables of guests, tidied so it is written one way
  /// only.
  List<List<int>> get tables => Rules.fromSeats(seats);

  int get laid => tables.length;

  List<int> get sizes => Rules.sizes(tables);

  String get mark => Rules.write(tables);

  /// Moves a guest to a trestle.
  Play sit(int guest, int trestle) {
    if (isOver) return this;
    if (guest < 0 || guest >= Rules.guests) return this;
    if (trestle < 0 || trestle >= trestles) return this;
    if (seats[guest] == trestle) return this;
    final to = [...seats]..[guest] = trestle;
    final at = Rules.write(Rules.fromSeats(to));
    return Play._(
      level: level,
      seats: to,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(tables);

  /// A hopeless ask, admitted: [enough] seatings tried, or [gaveUpAt]
  /// moves.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every seating that lands the ask, as seat lists, worked out once
  /// per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        final out = <List<int>>[];
        for (final seating in Rules.seatings()) {
          if (level.meets(seating)) out.add(Rules.seatOf(seating));
        }
        return out;
      });

  /// The moves between two seatings, which is one for every guest who
  /// has to get up. Tables have no names, so the two are lined up the
  /// way that moves fewest.
  static int between(List<int> from, List<int> to) {
    var fewest = Rules.guests;
    void walk(List<int> pairing, Set<int> used) {
      if (pairing.length == trestles) {
        var n = 0;
        for (var g = 0; g < Rules.guests; g++) {
          if (pairing[from[g]] != to[g]) n++;
        }
        if (n < fewest) fewest = n;
        return;
      }
      for (var t = 0; t < trestles; t++) {
        if (used.contains(t)) continue;
        walk([...pairing, t], {...used, t});
      }
    }

    walk(const [], <int>{});
    return fewest;
  }

  /// The nearest seating that lands the ask, and the moves to it.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final win in winners(level)) {
      final n = between(seats, win);
      if (away < 0 || n < away) {
        away = n;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the guest to move and the trestle to move
  /// them to. Null when there is nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // Line the winning seating's trestles up against this one the way
    // that moves fewest, then name the first guest still out of place.
    List<int>? bestPairing;
    var fewest = Rules.guests + 1;
    void walk(List<int> pairing, Set<int> used) {
      if (pairing.length == trestles) {
        var n = 0;
        for (var g = 0; g < Rules.guests; g++) {
          if (pairing[seats[g]] != near.$1[g]) n++;
        }
        if (n < fewest) {
          fewest = n;
          bestPairing = [...pairing];
        }
        return;
      }
      for (var t = 0; t < trestles; t++) {
        if (used.contains(t)) continue;
        walk([...pairing, t], {...used, t});
      }
    }

    walk(const [], <int>{});
    final pairing = bestPairing;
    if (pairing == null) return null;
    for (var g = 0; g < Rules.guests; g++) {
      if (pairing[seats[g]] == near.$1[g]) continue;
      // Send the guest to whichever trestle stands for the one the
      // winning seating puts them at.
      for (var t = 0; t < trestles; t++) {
        if (pairing[t] == near.$1[g]) return (g, t);
      }
    }
    return null;
  }

  /// The pointer's words.
  String pointed((int, int) aim) =>
      'Move ${Rules.name(aim.$1)} to trestle ${aim.$2 + 1}.';
}

/// Why the seatings come out as they do: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Six guests and a row of trestles. A seating is only which '
      'guests share a table: the trestles have no names, so carrying '
      'everybody from one to another changes nothing, and an empty '
      'trestle is no table at all.\n\n'
      'There are 203 seatings in all. Split by how many tables they use '
      'they come to 1, 31, 90, 65, 15 and 1, from everybody together to '
      'everybody apart, and those six numbers add to the 203.\n\n'
      'Those numbers can be had without writing a single seating down, '
      'and the reason is a thing you can do at the table. Take the last '
      'guest away and seat the other five somehow. Now bring the last '
      'guest back. Either they join one of the tables already laid, and '
      'there are as many ways to do that as there are tables, or they '
      'take a trestle of their own, which turns a seating of one table '
      'fewer into one of the right number. So the ways for six guests at '
      'k tables come to k times the ways for five at k, plus the ways '
      'for five at k less one. Stirling counted these, and the game '
      'works both the walk and the counting and holds them against each '
      'other on every number.\n\n'
      'The last ask needs no counting at all. Four tables holding four '
      'different numbers, with nobody left standing, need at least one '
      'guest, then two, then three, then four, which is ten guests. '
      'There are six. So it cannot be done here, and it could not be '
      'done with seven, eight or nine either.\n\n'
      'Every one of the 203 seatings was walked before the bake and held '
      'against the counting, and every ask on the list was counted both '
      'ways.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
