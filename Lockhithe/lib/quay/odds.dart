import 'stow.dart';

/// The crew's chances, three ways that share nothing.
///
/// The theorem is the game: a sailor who follows the chits, own locker
/// first, then the locker of whoever's chit they find, walks exactly the
/// loop their own locker sits on, and meets their own chit on its last
/// step. So the whole crew comes through exactly when no loop is longer
/// than the looks allowed, and the crew's fate was sealed the moment the
/// bosun stowed the chits.
///
/// The counting is a sum over long loops: a loop of length k more than
/// half arises in (n choose k)(k-1)!(n-k)! of the n! stowings, which
/// eases to n!/k, and long loops cannot share a stowing, so the chance of
/// failure is the sum of 1/k for k past the half. The sweep grinds every
/// stowing of eight lockers and simply counts. All three agree.
class Odds {
  const Odds._();

  /// The chance the crew comes through following the chits, by the sum:
  /// one minus the sum of 1/k for k from looks + 1 to lockers, as an
  /// exact pair of whole numbers.
  static (BigInt, BigInt) byCounting(int lockers, int looks) {
    var top = BigInt.zero;
    var bottom = BigInt.one;
    for (var k = looks + 1; k <= lockers; k++) {
      top = top * BigInt.from(k) + bottom;
      bottom *= BigInt.from(k);
    }
    // top/bottom is the failure chance; ease and flip.
    final whole = bottom;
    final win = whole - top;
    final common = win.gcd(bottom);
    return (win ~/ common, bottom ~/ common);
  }

  /// The same chance by grinding: every stowing of [lockers], counted
  /// through or not by its longest loop.
  static (BigInt, BigInt) bySweep(int lockers, int looks) {
    var through = 0;
    var all = 0;
    final chits = [for (var chit = 0; chit < lockers; chit++) chit];
    void grind(int from) {
      if (from == lockers) {
        all++;
        if (Stow(chits).longestLoop <= looks) through++;
        return;
      }
      for (var at = from; at < lockers; at++) {
        final swap = chits[from];
        chits[from] = chits[at];
        chits[at] = swap;
        grind(from + 1);
        chits[at] = chits[from];
        chits[from] = swap;
      }
    }

    grind(0);
    final top = BigInt.from(through);
    final bottom = BigInt.from(all);
    final common = top.gcd(bottom);
    return (top ~/ common, bottom ~/ common);
  }

  /// The chance every sailor comes through opening lockers at random,
  /// each on their own: the half raised to the crew, exact.
  static (BigInt, BigInt) byLuck(int lockers, int looks) {
    // Each sailor alone finds their chit in looks-of-lockers draws.
    final single = (BigInt.from(looks), BigInt.from(lockers));
    var top = BigInt.one;
    var bottom = BigInt.one;
    for (var sailor = 0; sailor < lockers; sailor++) {
      top *= single.$1;
      bottom *= single.$2;
    }
    final common = top.gcd(bottom);
    return (top ~/ common, bottom ~/ common);
  }
}
