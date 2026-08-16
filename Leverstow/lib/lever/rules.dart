import 'frac.dart';

/// A fairground machine with two levers and a purse that starts empty.
///
/// Lever A is a plain coin: it pays a coin one time in two and takes one
/// the rest. Lever B looks at the purse first. When three divides the
/// purse it pays only one time in ten; otherwise it pays three times in
/// four. Both levers are fair on their own, A because the coin is, and B
/// because of how often the purse lands on a multiple of three once it
/// has settled.
///
/// A loop is a pattern of levers, pulled round and round. Parrondo's
/// paradox, from Juan Parrondo in 1996, is that loops of two fair levers
/// climb: run A once and B twice, over and over, and the purse gains
/// 2416/35601 of a coin a round.
class Rules {
  /// The slots a loop may hold.
  static const least = 1, most = 12;

  /// The loop an ask opens on: one slot, holding the plain lever.
  static const opening = 'A';

  static const levers = ['A', 'B'];

  /// How often a lever pays, given what three leaves of the purse.
  static Frac odds(String lever, int rest) => lever == 'A'
      ? Frac.of(1, 2)
      : (rest == 0 ? Frac.of(1, 10) : Frac.of(3, 4));

  static bool valid(String loop) =>
      loop.length >= least &&
      loop.length <= most &&
      loop.split('').every(levers.contains);

  /// Whether the loop holds one lever and no other.
  static bool oneLever(String loop) =>
      loop.split('').toSet().length == 1;

  /// What three leaves of a purse, kept between 0 and 2 however the
  /// purse falls.
  static int rest(int purse) => ((purse % 3) + 3) % 3;

  /// One turn of the whole loop, folded into a map on the purse's
  /// remainder: how often it ends on each remainder having started on
  /// each, and the coins it wins on the way.
  static (List<List<Frac>>, List<Frac>) folded(String loop) {
    final map = [
      for (var start = 0; start < 3; start++) [Frac.zero, Frac.zero, Frac.zero],
    ];
    final won = [Frac.zero, Frac.zero, Frac.zero];
    for (var start = 0; start < 3; start++) {
      var spread = [Frac.zero, Frac.zero, Frac.zero];
      spread[start] = Frac.one;
      var gain = Frac.zero;
      for (final lever in loop.split('')) {
        final next = [Frac.zero, Frac.zero, Frac.zero];
        for (var r = 0; r < 3; r++) {
          final held = spread[r];
          if (held == Frac.zero) continue;
          final pays = odds(lever, r);
          gain = gain + held * (pays + pays - Frac.one);
          next[(r + 1) % 3] = next[(r + 1) % 3] + held * pays;
          next[(r + 2) % 3] = next[(r + 2) % 3] + held * (Frac.one - pays);
        }
        spread = next;
      }
      map[start] = spread;
      won[start] = gain;
    }
    return (map, won);
  }

  /// Gaussian elimination over exact fractions, or null when the rows
  /// do not settle it.
  static List<Frac>? solve(List<List<Frac>> rows, List<Frac> sides) {
    final n = sides.length;
    final a = [for (final row in rows) List.of(row)];
    final b = List.of(sides);
    for (var i = 0; i < n; i++) {
      var pivot = -1;
      for (var k = i; k < n; k++) {
        if (a[k][i] != Frac.zero) {
          pivot = k;
          break;
        }
      }
      if (pivot < 0) return null;
      final rowI = a[i];
      a[i] = a[pivot];
      a[pivot] = rowI;
      final sideI = b[i];
      b[i] = b[pivot];
      b[pivot] = sideI;
      final by = a[i][i];
      a[i] = [for (final x in a[i]) x / by];
      b[i] = b[i] / by;
      for (var k = 0; k < n; k++) {
        if (k == i || a[k][i] == Frac.zero) continue;
        final f = a[k][i];
        a[k] = [for (var j = 0; j < n; j++) a[k][j] - f * a[i][j]];
        b[k] = b[k] - f * b[i];
      }
    }
    return b;
  }

  /// The share of turns of the loop that start on each remainder, once
  /// the machine has settled.
  static List<Frac> resting(String loop) {
    final (map, _) = folded(loop);
    final rows = [
      for (var i = 0; i < 3; i++)
        [for (var j = 0; j < 3; j++) map[j][i] - (i == j ? Frac.one : Frac.zero)],
    ];
    rows[2] = [Frac.one, Frac.one, Frac.one];
    final settled = solve(rows, [Frac.zero, Frac.zero, Frac.one]);
    return settled ?? [Frac.zero, Frac.zero, Frac.zero];
  }

  /// How many coins a round the purse climbs once the machine has
  /// settled: the first voice, which folds the loop to three
  /// remainders.
  static Frac climb(String loop) {
    final (_, won) = folded(loop);
    final share = resting(loop);
    var total = Frac.zero;
    for (var r = 0; r < 3; r++) {
      total = total + share[r] * won[r];
    }
    return total / Frac.of(loop.length);
  }

  /// The same climb off the long chain, one state for each remainder in
  /// each slot of the loop, with no folding at all: the second voice.
  static Frac climbByChain(String loop) {
    final slots = loop.length;
    final states = 3 * slots;
    int at(int slot, int r) => slot * 3 + r;
    final step = [
      for (var i = 0; i < states; i++) [for (var j = 0; j < states; j++) Frac.zero],
    ];
    final won = [for (var i = 0; i < states; i++) Frac.zero];
    for (var slot = 0; slot < slots; slot++) {
      final lever = loop[slot];
      final onward = (slot + 1) % slots;
      for (var r = 0; r < 3; r++) {
        final pays = odds(lever, r);
        step[at(slot, r)][at(onward, (r + 1) % 3)] = pays;
        step[at(slot, r)][at(onward, (r + 2) % 3)] = Frac.one - pays;
        won[at(slot, r)] = pays + pays - Frac.one;
      }
    }
    final rows = [
      for (var i = 0; i < states; i++)
        [
          for (var j = 0; j < states; j++)
            step[j][i] - (i == j ? Frac.one : Frac.zero),
        ],
    ];
    rows[states - 1] = [for (var j = 0; j < states; j++) Frac.one];
    final sides = [
      for (var i = 0; i < states; i++) i == states - 1 ? Frac.one : Frac.zero,
    ];
    final share = solve(rows, sides);
    if (share == null) return Frac.zero;
    var total = Frac.zero;
    for (var i = 0; i < states; i++) {
      total = total + share[i] * won[i];
    }
    return total;
  }

  /// What the purse comes to after each of [rounds] rounds, exactly,
  /// carrying the whole spread of purses rather than an average.
  static List<Frac> purse(String loop, int rounds) {
    var spread = <int, Frac>{0: Frac.one};
    final out = <Frac>[];
    for (var t = 0; t < rounds; t++) {
      final lever = loop[t % loop.length];
      final next = <int, Frac>{};
      spread.forEach((held, share) {
        final pays = odds(lever, rest(held));
        next[held + 1] = (next[held + 1] ?? Frac.zero) + share * pays;
        next[held - 1] =
            (next[held - 1] ?? Frac.zero) + share * (Frac.one - pays);
      });
      spread = next;
      var mean = Frac.zero;
      spread.forEach((held, share) {
        mean = mean + Frac.of(held) * share;
      });
      out.add(mean);
    }
    return out;
  }

  /// The purse after [rounds] rounds worked out the plain way, by
  /// walking every run of wins and losses there is and weighing each by
  /// how often it happens. Two to the rounds of them, so short runs
  /// only.
  static Frac purseByEveryRun(String loop, int rounds) {
    var total = Frac.zero;
    void walk(int t, int held, Frac share) {
      if (t == rounds) {
        total = total + Frac.of(held) * share;
        return;
      }
      final pays = odds(loop[t % loop.length], rest(held));
      walk(t + 1, held + 1, share * pays);
      walk(t + 1, held - 1, share * (Frac.one - pays));
    }

    walk(0, 0, Frac.one);
    return total;
  }

  /// How many taps it takes to build [to] out of [from]: one for each
  /// slot added or taken away, and one for each slot that has to change
  /// lever. A slot comes in holding the plain lever.
  static int cost(String from, String to) {
    var taps = (from.length - to.length).abs();
    final padded = from.length < to.length
        ? from + 'A' * (to.length - from.length)
        : from;
    for (var i = 0; i < to.length; i++) {
      if (padded[i] != to[i]) taps++;
    }
    return taps;
  }

  /// Every loop of [least] to [most] slots, in order.
  static Iterable<String> loops() sync* {
    for (var length = least; length <= most; length++) {
      for (var mask = 0; mask < (1 << length); mask++) {
        yield [
          for (var i = 0; i < length; i++) (mask >> i) & 1 == 1 ? 'B' : 'A',
        ].join();
      }
    }
  }

  static String tellLoop(String loop) => loop.split('').join(' ');
}
