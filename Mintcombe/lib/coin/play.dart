import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the coins laid on the counter in order, the taps
/// taken, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.picked,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : picked = const [],
        moves = 0,
        before = null;

  /// A go standing at a picking, no taps counted: what the mark draws.
  Play.standing(this.level, this.picked)
      : moves = 0,
        before = null;

  final Level level;

  /// The coins laid, in the order laid.
  final List<int> picked;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets stuck.
  static const gaveUpAt = 16;

  int get sum => Rules.sumOf(picked);

  int get left => level.price - sum;

  bool get tidy => Rules.tidy(picked);

  /// The neighbouring pairs laid, dearer coin first.
  List<(int, int)> get pairs => Rules.neighbourPairs(picked);

  /// Whether [coin] can be laid: on the rack, not laid, not kept back,
  /// and not over the price.
  bool fits(int coin) => Rules.coins.contains(coin) && !picked.contains(coin) && coin != level.barred && sum + coin <= level.price;

  /// Whether no coin can be laid tidily any more, the picking tidy as it
  /// stands: what the hopeless ask admits at.
  bool get stuck => picked.isNotEmpty && tidy && !Rules.coins.any((c) => fits(c) && Rules.tidy([...picked, c]));

  /// Lays [coin] on the counter, if it fits.
  Play pick(int coin) {
    if (isOver || !fits(coin)) return this;
    return Play._(level: level, picked: [...picked, coin], moves: moves + 1, before: this);
  }

  /// Takes [coin] back to the rack.
  Play lift(int coin) {
    if (isOver || !picked.contains(coin)) return this;
    return Play._(level: level, picked: [for (final c in picked) if (c != coin) c], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(picked);

  /// A hopeless ask, admitted: stuck tidy short of the price, or
  /// [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (stuck || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (coin, lift), a laid coin off the aim taken
  /// back first, then the aim's next coin laid, dearest first; null when
  /// there is nothing to point at.
  (int, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (final c in picked.reversed) {
      if (!aim.contains(c)) return (c, true);
    }
    for (final c in aim) {
      if (!picked.contains(c)) return (c, false);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, bool) aim) => aim.$2 ? 'Take back the ${aim.$1}.' : 'Lay the ${aim.$1}.';
}

/// Why every price is paid tidily once: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The mint strikes coins of 1, 2, 3, 5, 8, 13, 21, 34, 55 and 89, each '
      'the two before it added, and the purse holds one of each. Call a '
      'picking tidy when no two of its coins sit side by side on the rack. '
      'Every price from nought to 143 is paid tidily in exactly one way, and '
      'the way is the greedy one, the dearest coin not over what is left, '
      'again and again: Lekkerkerker showed it in 1952 and Zeckendorf in '
      '1972, and the theorem carries his name. The reason is a run of '
      'alternate coins: every other coin from a coin down adds to one short '
      'of the coin above it, 55, 21, 8, 3 and 1 to 88, so without the dearest '
      'coin that fits a price no tidy picking reaches it, and with it the '
      'rest is a smaller price paid the same way.\n\n'
      'The game takes every picking of the purse, 1,024, sums each and finds '
      'the tidy ones, 144 of them paying the 144 prices from nought to 143 '
      'once each and none higher; and it runs the greedy purse on every '
      'price to 143 and finds it landing the tidy picking every time, with '
      'the fewest coins any picking uses.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every picking of the purse, '
      'summed in full.';
}
