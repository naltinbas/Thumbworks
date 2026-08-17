import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the grain stands, the shares made, and the
/// go before, so a share can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.bins,
    required this.holding,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : bins = Rules.opening,
        holding = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at an arrangement, no shares counted: what the mark
  /// draws.
  Play.standing(this.level, this.bins, {this.holding})
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// How much grain each bin holds.
  final List<int> bins;

  /// The bin a measure has been lifted from, waiting to be put down.
  final int? holding;

  /// The shares made.
  final int moves;

  /// The arrangements tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The shares a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The arrangements a hopeless ask lets the player make before the
  /// sham admits it.
  static const enough = 4;

  List<int> get shape => Rules.shape(bins);

  List<int> get running => Rules.running(shape);

  /// Whether anything can move at all.
  bool get settled {
    for (var from = 0; from < Rules.bins; from++) {
      for (var to = 0; to < Rules.bins; to++) {
        if (Rules.canShare(bins, from, to)) return false;
      }
    }
    return true;
  }

  bool canTake(int bin) {
    for (var to = 0; to < Rules.bins; to++) {
      if (Rules.canShare(bins, bin, to)) return true;
    }
    return false;
  }

  bool canGive(int bin) =>
      holding != null && Rules.canShare(bins, holding!, bin);

  Play _to(List<int> to) {
    final at = to.join(',');
    return Play._(
      level: level,
      bins: to,
      holding: null,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Taps a bin: lifts a measure out of it, puts a held measure into
  /// it, or puts the held measure back where it came from.
  Play tap(int bin) {
    if (isOver) return this;
    if (holding == null) {
      if (!canTake(bin)) return this;
      return Play._(
        level: level,
        bins: bins,
        holding: bin,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    if (holding == bin) {
      return Play._(
        level: level,
        bins: bins,
        holding: null,
        moves: moves,
        seen: seen,
        before: before,
      );
    }
    if (!Rules.canShare(bins, holding!, bin)) return this;
    return _to(Rules.share(bins, holding!, bin));
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(bins);

  /// A hopeless ask, admitted: [enough] arrangements tried, or
  /// [gaveUpAt] shares made.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every arrangement standing in the shape the ask wants, worked out
  /// once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final at in Rules.arrangements())
            if (level.meets(at)) at,
        ];
      });

  /// The fewest shares from here to the shape the ask wants, and the
  /// share to make first. Walked outward from where the bins stand.
  (int, (int, int))? get toGo {
    if (level.meets(bins)) return (0, (0, 0));
    final seen = <String, (int, int)?>{bins.join(','): null};
    final queue = <List<int>>[bins];
    final away = <String, int>{bins.join(','): 0};
    for (var head = 0; head < queue.length; head++) {
      final at = queue[head];
      for (var from = 0; from < Rules.bins; from++) {
        for (var to = 0; to < Rules.bins; to++) {
          if (!Rules.canShare(at, from, to)) continue;
          final next = Rules.share(at, from, to);
          final key = next.join(',');
          if (seen.containsKey(key)) continue;
          seen[key] = identical(at, bins)
              ? (from, to)
              : seen[at.join(',')];
          away[key] = away[at.join(',')]! + 1;
          if (level.meets(next)) return (away[key]!, seen[key]!);
          queue.add(next);
        }
      }
    }
    return null;
  }

  /// What the pointer says, or null when there is nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final go = toGo;
    if (go == null || go.$1 == 0) return null;
    return go.$2;
  }

  /// The pointer's words, given what the hand is holding.
  static String pointed((int, int) aim, int? holding) {
    if (holding == null) return 'Take a measure out of bin ${aim.$1 + 1}.';
    if (holding == aim.$1) return 'Put the measure in bin ${aim.$2 + 1}.';
    return 'Put the measure back in bin ${holding + 1}.';
  }
}

/// Why the fullest bin never rises: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Five bins and ten measures of grain. A share takes one measure out '
      'of a fuller bin and puts it in an emptier one, and only where the '
      'fuller bin is at least two ahead: take from a bin only one ahead and '
      'it ends up behind, which is a swap and not a sharing out.\n\n'
      'Line the bins up tallest first and add them along: the fullest, then '
      'the two fullest together, then the three, and so on. A share can '
      'never raise any of those running totals. The measure leaves a bin that '
      'is counted no later than the bin it lands in, so every total either '
      'keeps its measure or loses one. That is the whole rule, and it works '
      'the other way too: a shape can be reached from another exactly when '
      'every one of its running totals is no greater. This is majorization, '
      'and the shares are the Robin Hood transfers that go with it.\n\n'
      'So the fullest bin never rises, which is why the grain can never be '
      'gathered back into one heap once it has been spread, and why the level '
      'field, where every total is as small as it can be, can always be '
      'reached and can never be left.\n\n'
      'The sham works it both ways: it walks every share-out from every one '
      'of the 1,001 arrangements the grain can stand in, and it compares the '
      'running totals, which moves no grain at all. The two agree on every '
      'arrangement and every shape.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every arrangement walked in '
      'full before the sham was built.';
}
