/// A counting house with five wheels. The first wheel turns 0 or 1, the
/// second 0 to 2, the third 0 to 3, the fourth 0 to 4, the fifth 0 to
/// 5, and each one is worth the factorial of its place: 1, 2, 6, 24,
/// 120. A reading is the wheels added up, each times its worth.
///
/// Every number from nothing up to 719 reads exactly one way, and 719
/// is as high as the wheels go, because k times k factorial is (k + 1)
/// factorial less k factorial, so the wheels at their tops telescope to
/// 6 factorial less one. Turn them all up and the house stands one
/// short of rolling over.
class Rules {
  /// The wheels, the first the cheapest.
  static const wheels = 5;

  /// The reading a go opens on: every wheel at nothing.
  static List<int> get opening => List.filled(wheels, 0);

  /// How high wheel [k] turns, counting the wheels from 1.
  static int top(int k) => k;

  /// What one turn of wheel [k] is worth: k factorial.
  static int worth(int k) {
    var out = 1;
    for (var i = 2; i <= k; i++) {
      out *= i;
    }
    return out;
  }

  /// The highest the house reads.
  static int get most {
    var out = 0;
    for (var k = 1; k <= wheels; k++) {
      out += top(k) * worth(k);
    }
    return out;
  }

  /// How many readings the wheels have.
  static int get howManyReadings {
    var out = 1;
    for (var k = 1; k <= wheels; k++) {
      out *= top(k) + 1;
    }
    return out;
  }

  static bool valid(List<int> at) =>
      at.length == wheels &&
      [for (var k = 1; k <= wheels; k++) at[k - 1] >= 0 && at[k - 1] <= top(k)]
          .every((ok) => ok);

  /// The first voice: the wheels added up, each times its worth.
  static int reading(List<int> at) {
    var out = 0;
    for (var k = 1; k <= wheels; k++) {
      out += at[k - 1] * worth(k);
    }
    return out;
  }

  /// The turns it takes to get from one reading to another, a wheel a
  /// turn.
  static int turns(List<int> from, List<int> to) {
    var out = 0;
    for (var k = 0; k < wheels; k++) {
      out += (from[k] - to[k]).abs();
    }
    return out;
  }

  /// The wheels that read [number], found by dividing rather than by
  /// adding: the second voice.
  static List<int>? wheelsFor(int number) {
    if (number < 0 || number > most) return null;
    final at = List.filled(wheels, 0);
    var left = number;
    for (var k = 1; k <= wheels; k++) {
      at[k - 1] = left % (k + 1);
      left ~/= k + 1;
    }
    return left == 0 ? at : null;
  }

  /// Turns the house up by one, carrying as an odometer does. Null when
  /// it stands at its top and has nowhere to go.
  static List<int>? tickUp(List<int> at) {
    final out = List.of(at);
    for (var k = 1; k <= wheels; k++) {
      if (out[k - 1] < top(k)) {
        out[k - 1]++;
        return out;
      }
      out[k - 1] = 0;
    }
    return null;
  }

  /// Every reading the wheels have, in odometer order.
  static List<List<int>> readings() {
    final out = <List<int>>[];
    List<int>? at = opening;
    while (at != null) {
      out.add(at);
      at = tickUp(at);
    }
    return out;
  }

  static String tellWheels(List<int> at) => [
        for (var k = wheels; k >= 1; k--) '${at[k - 1]}',
      ].join(' ');

  static String tellWorth(int k) => '$k!';
}
