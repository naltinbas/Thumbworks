/// The law of the village: a fever afflicts one soul in [prevalence]; the
/// physician's test flags the ill [catchNum] times in [catchDen], and
/// wrongly flags the well [alarmNum] times in [alarmDen]. Of the
/// villagers flagged, the share that are ill is the ill flagged over
/// all flagged, which is Bayes' theorem read as counting: in a village
/// of ten million souls every count is a whole number, and the share is
/// the same as the exact fraction of chances.
class Rules {
  /// The fever's rates on the sham: one soul in each of these.
  static const prevalences = [2, 5, 10, 20, 50, 100, 200, 500, 1000];

  /// The test's catch of the ill, and its false alarm on the well, as
  /// (numerator, denominator).
  static const catches = [(9, 10), (19, 20), (99, 100), (999, 1000), (1, 1)];
  static const alarms = [(1, 10), (1, 20), (1, 100), (1, 1000), (0, 1)];

  /// The village, big enough that every count is whole.
  static const souls = 10000000;

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  static (int, int) fraction(int num, int den) {
    if (num == 0) return (0, 1);
    final g = gcd(num.abs(), den.abs());
    return (num ~/ g, den ~/ g);
  }

  /// The village counted: ill, well, ill flagged, well flagged.
  static (int, int, int, int) counted(int prevalence, (int, int) catchRate, (int, int) alarm) {
    final ill = souls ~/ prevalence;
    final well = souls - ill;
    final illFlagged = ill * catchRate.$1 ~/ catchRate.$2;
    final wellFlagged = well * alarm.$1 ~/ alarm.$2;
    return (ill, well, illFlagged, wellFlagged);
  }

  /// The share of the flagged that are ill, by counting the village.
  static (int, int) byCounting(int prevalence, (int, int) catchRate, (int, int) alarm) {
    final (_, _, illFlagged, wellFlagged) = counted(prevalence, catchRate, alarm);
    if (illFlagged + wellFlagged == 0) return (0, 1);
    return fraction(illFlagged, illFlagged + wellFlagged);
  }

  /// The share by Bayes as fractions of chances: prevalence times catch
  /// over that plus (one less prevalence) times alarm.
  static (int, int) byChances(int prevalence, (int, int) catchRate, (int, int) alarm) {
    // ill and flagged: (1/p)(c/d); well and flagged: ((p-1)/p)(a/b)
    final (c, d) = catchRate;
    final (a, b) = alarm;
    final illNum = c * b, wellNum = (prevalence - 1) * a * d;
    // both over p * d * b
    if (illNum + wellNum == 0) return (0, 1);
    return fraction(illNum, illNum + wellNum);
  }

  /// Whether the village's counts all come whole.
  static bool whole(int prevalence, (int, int) catchRate, (int, int) alarm) {
    final ill = souls ~/ prevalence;
    return souls % prevalence == 0 && (ill * catchRate.$1) % catchRate.$2 == 0 && ((souls - ill) * alarm.$1) % alarm.$2 == 0;
  }

  /// Every setting of the sham, asked, and how many meet the ask, with
  /// the count of settings.
  static (int, int) sweep(bool Function(int prevalence, (int, int) catchRate, (int, int) alarm) ask) {
    var met = 0, all = 0;
    for (final p in prevalences) {
      for (final c in catches) {
        for (final a in alarms) {
          all++;
          if (ask(p, c, a)) met++;
        }
      }
    }
    return (met, all);
  }

  /// The first setting meeting [ask], or null.
  static (int, (int, int), (int, int))? first(bool Function(int, (int, int), (int, int)) ask) {
    for (final p in prevalences) {
      for (final c in catches) {
        for (final a in alarms) {
          if (ask(p, c, a)) return (p, c, a);
        }
      }
    }
    return null;
  }

  static int compare((int, int) x, (int, int) y) => (x.$1 * y.$2 - y.$1 * x.$2).sign;

  static String inHundred((int, int) f) {
    final scaled = f.$1 * 10000 ~/ f.$2;
    return '${scaled ~/ 100}.${(scaled % 100).toString().padLeft(2, '0')}';
  }

  /// A rate told: 'nine in ten', 'none', 'every one'.
  static String told((int, int) rate) {
    if (rate == (1, 1)) return 'every one';
    if (rate == (0, 1)) return 'none';
    return '${_number(rate.$1)} in ${_number(rate.$2)}';
  }

  static String _number(int n) => switch (n) {
        1 => 'one',
        9 => 'nine',
        10 => 'ten',
        19 => 'nineteen',
        20 => 'twenty',
        99 => 'ninety-nine',
        100 => 'a hundred',
        999 => 'nine hundred and ninety-nine',
        1000 => 'a thousand',
        _ => '$n',
      };
}
