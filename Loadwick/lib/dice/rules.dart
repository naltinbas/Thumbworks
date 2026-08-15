/// The law of the dice: two dice rolled together, thirty-six rolls, and
/// the die that shows the higher face wins the roll; a die beats another
/// when it wins more than half the thirty-six.
class Rules {
  const Rules();

  /// Efron's four dice, named A to D, and their faces.
  static const names = ['A', 'B', 'C', 'D'];

  static const dice = [
    [4, 4, 4, 4, 0, 0],
    [3, 3, 3, 3, 3, 3],
    [6, 6, 2, 2, 2, 2],
    [5, 5, 5, 1, 1, 1],
  ];

  /// How many of the thirty-six rolls die [x] wins against die [y].
  static int wins(List<int> x, List<int> y) {
    var n = 0;
    for (final a in x) {
      for (final b in y) {
        if (a > b) n++;
      }
    }
    return n;
  }

  static int ties(List<int> x, List<int> y) {
    var n = 0;
    for (final a in x) {
      for (final b in y) {
        if (a == b) n++;
      }
    }
    return n;
  }

  /// Whether [x] beats [y]: more than eighteen rolls of the thirty-six.
  static bool beats(List<int> x, List<int> y) => wins(x, y) > 18;

  /// The dice among the four that beat die [y].
  static List<int> beaters(int y) => [
        for (var x = 0; x < 4; x++)
          if (x != y && beats(dice[x], dice[y])) x,
      ];

  /// The dice among the four that beat every other.
  static List<int> get champions => [
        for (var x = 0; x < 4; x++)
          if ([for (var y = 0; y < 4; y++) if (y != x) y].every((y) => beats(dice[x], dice[y]))) x,
      ];

  /// Every die with faces from nought to six, told once each as a rising
  /// list, and how many beat all four of Efron's, or beat none, or beat
  /// a given one: (all, beatingAll, beatingNone, beatingEach).
  static (int, int, int, List<int>) sweep() {
    var all = 0, beatingAll = 0, beatingNone = 0;
    final each = [0, 0, 0, 0];
    void go(List<int> faces, int from) {
      if (faces.length == 6) {
        all++;
        var count = 0;
        for (var y = 0; y < 4; y++) {
          if (beats(faces, dice[y])) {
            count++;
            each[y]++;
          }
        }
        if (count == 4) beatingAll++;
        if (count == 0) beatingNone++;
        return;
      }
      for (var f = from; f <= 6; f++) {
        go([...faces, f], f);
      }
    }

    go([], 0);
    return (all, beatingAll, beatingNone, each);
  }
}
