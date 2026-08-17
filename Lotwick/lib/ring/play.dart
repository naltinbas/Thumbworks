import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three dials, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.worth,
    required this.bid,
    required this.rival,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : worth = Rules.openWorth,
        bid = Rules.openBid,
        rival = Rules.openRival,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.worth, this.bid, this.rival)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// What the beast is worth to you, what you bid, and the best bid
  /// against you.
  final int worth, bid, rival;

  /// The taps taken.
  final int moves;

  /// The settings tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The settings a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 4;

  String get ring => level.ring;

  bool get takesIt => Rules.wins(bid, rival);

  /// What this bid earns.
  int get paid => Rules.paidBy(ring, worth, bid, rival);

  /// What the truthful bid would earn against the same rival.
  int get truthPaid => Rules.truthPays(ring, worth, rival);

  /// What the bid earns against a rival who bids [against].
  int paidAgainst(int against) =>
      Rules.paidBy(ring, worth, bid, against);

  int truthAgainst(int against) => Rules.truthPays(ring, worth, against);

  /// The gap between the bid and the truth, by the window argument.
  int get gap => Rules.windowGap(worth, bid, rival);

  Play _to(int worth, int bid, int rival) {
    final at = '$worth,$bid,$rival';
    return Play._(
      level: level,
      worth: worth,
      bid: bid,
      rival: rival,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Steps one dial: 0 the worth, 1 the bid, 2 the rival.
  Play step(int dial, int by) {
    if (isOver || by == 0) return this;
    final at = [worth, bid, rival];
    at[dial] += by;
    if (at[dial] < 0 || at[dial] > Rules.most) return this;
    return _to(at[0], at[1], at[2]);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(worth, bid, rival);

  /// A hopeless ask, admitted: [enough] settings tried, or [gaveUpAt]
  /// taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every setting that lands the ask, worked out once per ask.
  static final Map<String, List<(int, int, int)>> _winners = {};

  static List<(int, int, int)> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final (worth, bid, rival) in Rules.settings())
            if (level.meets(worth, bid, rival)) (worth, bid, rival),
        ];
      });

  /// The nearest setting that lands the ask, and how many taps away it
  /// is.
  ((int, int, int), int)? get nearest {
    (int, int, int)? best;
    var away = -1;
    for (final win in winners(level)) {
      final taps = Rules.taps((worth, bid, rival), win);
      if (away < 0 || taps < away) {
        away = taps;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: (dial, way); null when there is nothing to
  /// point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    final at = [worth, bid, rival];
    final want = [near.$1.$1, near.$1.$2, near.$1.$3];
    for (var dial = 0; dial < 3; dial++) {
      if (at[dial] != want[dial]) {
        return (dial, at[dial] < want[dial] ? 1 : -1);
      }
    }
    return null;
  }

  static const dials = ['worth', 'bid', 'rival'];

  /// The pointer's words.
  static String pointed((int, int) aim) {
    final what = switch (aim.$1) {
      0 => 'what the beast is worth to you',
      1 => 'your bid',
      _ => 'the best bid against you',
    };
    return aim.$2 > 0 ? 'Put $what up a crown.' : 'Put $what down a crown.';
  }
}

/// Why no bid beats the truth in the sealed ring: the words behind the
/// Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'You know what the beast is worth to you. The rivals write their '
      'bids, you write yours, and the highest bid takes it; a tie goes to '
      'them, so you win only when your bid is strictly the highest. Only the '
      'best rival bid can ever matter, which is why three dials tell the '
      'whole story.\n\n'
      'In the sealed ring the winner pays the second bid, so when you win you '
      'pay what the best rival bid, not what you bid. Your own bid never sets '
      'the price. All it settles is whether you win.\n\n'
      'So look at what moving it can do. Push it above the worth and the only '
      'extra beasts you take are the ones where the best rival bid already '
      'sits at or above the worth: you pay at least what they are worth to '
      'you, so you gain nothing and you lose outright whenever that bid is '
      'above the worth. Pull it under and the only beasts you drop are the '
      'ones where the best rival bid sits under the worth: you would have '
      'taken those and been in pocket. Neither way can gain, and in between '
      'nothing changes at all. William Vickrey published this in 1961.\n\n'
      'The open ring is the other story. There the winner pays what he bid, '
      'so bidding the worth wins beasts that earn nothing, and shading under '
      'the worth is what pays. That is the ring the sealed one was invented '
      'to fix.\n\n'
      'The sham works every setting twice: once by running the auction, '
      'sorting the bids and charging the ring\'s price, and once by the '
      'window, which runs no auction and says the two bids differ only when '
      'the best rival bid falls between them, closed at the lower end because '
      'a bid level with a rival loses.\n\n'
      'This is ask $number, ${level.name}, run in ${Rules.tellRing(level.ring)}. '
      '${level.note}\n\n'
      'The counts in this note are the sweep\'s: every setting of the three '
      'dials, run in full before the sham was built.';
}
