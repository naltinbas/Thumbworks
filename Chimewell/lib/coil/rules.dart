import 'dart:math';

/// The arithmetic of the coil: a note is the start climbed by some
/// fifths and some octaves, and it is kept as an exact fraction of the
/// start, 3 to the fifths over 2 to the fifths, times 2 to the octaves.
/// Nothing here rounds until it is asked for cents, and the cents are the
/// second voice, checked against the fractions by the checker.
class Rules {
  /// The dials run this far either way.
  static const fifths = 12;
  static const octaves = 8;

  /// How many settings the two dials have between them: 25 by 17.
  static const settings = (2 * fifths + 1) * (2 * octaves + 1);

  static final _two = BigInt.two, _three = BigInt.from(3);

  /// The note [f] fifths and [o] octaves from the start, as a fraction in
  /// lowest terms: 3 and 2 share no factor, so it is in lowest terms as
  /// built.
  static (BigInt, BigInt) note(int f, int o) {
    var num = BigInt.one, den = BigInt.one;
    if (f >= 0) {
      num *= _three.pow(f);
    } else {
      den *= _three.pow(-f);
    }
    final e = o - f;
    if (e >= 0) {
      num *= _two.pow(e);
    } else {
      den *= _two.pow(-e);
    }
    return (num, den);
  }

  /// The second voice: cents by the dials, twelve hundred a turn, the
  /// fifth being twelve hundred times the log of three halves.
  static double cents(int f, int o) => 1200 * (f * (log(3) / log(2)) + o - f);

  /// Cents by the fraction, for the checker to hold against [cents].
  static double centsOf((BigInt, BigInt) r) => 1200 * log(r.$1.toDouble() / r.$2.toDouble()) / log(2);

  /// Whether the note is within one [part]th of the start either way:
  /// part times the gap between the two numbers is at most the bottom.
  static bool within((BigInt, BigInt) r, int part) => (r.$1 - r.$2).abs() * BigInt.from(part) <= r.$2;

  /// Whether the note is the start itself.
  static bool home((BigInt, BigInt) r) => r.$1 == r.$2;

  /// Whether the note is above the start.
  static bool sharp((BigInt, BigInt) r) => r.$1 > r.$2;

  /// Sweeps every setting of the two dials: how many meet [ask], how many
  /// there are, and the first that meets it, fifths climbing from the
  /// bottom of the dial and octaves within each.
  static (int, int, (int, int)?) sweep(bool Function(int f, int o) ask) {
    var met = 0, all = 0;
    (int, int)? first;
    for (var f = -fifths; f <= fifths; f++) {
      for (var o = -octaves; o <= octaves; o++) {
        all++;
        if (ask(f, o)) {
          met++;
          first ??= (f, o);
        }
      }
    }
    return (met, all, first);
  }

  /// The setting, told: 'two fifths up and one octave down'.
  static String told(int f, int o) {
    final a = f == 0 ? 'no fifths' : '${count(f.abs())} ${f.abs() == 1 ? 'fifth' : 'fifths'} ${f > 0 ? 'up' : 'down'}';
    final b = o == 0 ? 'no octaves' : '${count(o.abs())} ${o.abs() == 1 ? 'octave' : 'octaves'} ${o > 0 ? 'up' : 'down'}';
    return '$a and $b';
  }

  /// The fraction, told with commas: '531,441/524,288'.
  static String fraction((BigInt, BigInt) r) => '${commas(r.$1)}/${commas(r.$2)}';

  /// Cents to the hundredth, signed by sharp or flat.
  static String centsTold(double c) => '${c.abs().toStringAsFixed(2)} cents ${c < 0 ? 'flat' : 'sharp'}';

  static String commas(BigInt n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  static const _words = [
    'no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
    'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen',
    'eighteen', 'nineteen', 'twenty',
  ];

  static String count(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
}
