/// The arithmetic of the thread: nails round a hoop, a thread that goes
/// from nail to nail skipping the same count each time, and the strokes
/// it takes to touch every nail. Two voices: the walk, which follows the
/// thread nail by nail until it comes home and starts again from the
/// first bare nail; and the divisor, which says a stroke touches the
/// count over the greatest common divisor of count and skip, and so the
/// strokes are the divisor itself.
class Rules {
  /// The dial of nails runs from [fewest] to [most]; the skip from one to
  /// a nail short of the count.
  static const fewest = 5;
  static const most = 12;

  /// How many settings the two dials have between them: for each count
  /// of nails, every skip from one to the count less one.
  static int get settings {
    var n = 0;
    for (var nails = fewest; nails <= most; nails++) {
      n += nails - 1;
    }
    return n;
  }

  /// The strokes, walked: each a list of the nails it touches in order,
  /// the first from nail 0, each next from the first nail no stroke has
  /// touched, until every nail is touched.
  static List<List<int>> strokes(int nails, int skip) {
    final touched = List.filled(nails, false);
    final out = <List<int>>[];
    for (var start = 0; start < nails; start++) {
      if (touched[start]) continue;
      final stroke = <int>[];
      var at = start;
      do {
        stroke.add(at);
        touched[at] = true;
        at = (at + skip) % nails;
      } while (at != start);
      out.add(stroke);
    }
    return out;
  }

  /// The strokes, by the divisor: as many as the count and the skip
  /// share, each touching the count over that.
  static int strokesByDivisor(int nails, int skip) => nails.gcd(skip);

  static int nailsAStrokeByDivisor(int nails, int skip) => nails ~/ nails.gcd(skip);

  /// Whether the setting draws a star at all: a skip of one, or one
  /// short of the count, only runs round the rim.
  static bool isStar(int nails, int skip) => skip >= 2 && skip <= nails - 2;

  /// The lines a setting draws, each as (low nail, high nail), sorted and
  /// without repeats: skip k and skip nails - k draw the same lines.
  static List<(int, int)> lines(int nails, int skip) {
    final set = <(int, int)>{};
    for (final stroke in strokes(nails, skip)) {
      for (var i = 0; i < stroke.length; i++) {
        final a = stroke[i], b = stroke[(i + 1) % stroke.length];
        if (a == b) continue;
        set.add(a < b ? (a, b) : (b, a));
      }
    }
    final out = set.toList()..sort((p, q) => p.$1 != q.$1 ? p.$1 - q.$1 : p.$2 - q.$2);
    return out;
  }

  /// The skips that thread a star of [nails] in one stroke, by the walk.
  static List<int> oneStrokeStars(int nails) => [
        for (var skip = 2; skip <= nails - 2; skip++)
          if (strokes(nails, skip).length == 1) skip,
      ];

  /// How many skips share no factor with [nails], counted one by one:
  /// Euler's count, and the one-stroke stars are that less two, halved.
  static int coprimes(int nails) {
    var n = 0;
    for (var k = 1; k <= nails; k++) {
      if (nails.gcd(k) == 1) n++;
    }
    return n;
  }

  /// Sweeps every setting of the two dials: how many meet [ask], how many
  /// there are, and the first that meets it.
  static (int, int, (int, int)?) sweep(bool Function(int nails, int skip) ask) {
    var met = 0, all = 0;
    (int, int)? first;
    for (var nails = fewest; nails <= most; nails++) {
      for (var skip = 1; skip < nails; skip++) {
        all++;
        if (ask(nails, skip)) {
          met++;
          first ??= (nails, skip);
        }
      }
    }
    return (met, all, first);
  }

  static const _words = ['no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve'];

  static String count(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
}
