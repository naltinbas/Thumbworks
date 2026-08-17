/// A yard with one siding. Six wagons stand on the main line in the
/// order 1 to 6 and leave by the far end. A wagon can roll straight
/// past the siding, or be shunted onto it; a wagon on the siding can be
/// sent out, but only the one nearest the points, which is the last one
/// shunted.
///
/// So the out-train can be in any order the siding can make, and no
/// other. Those orders are exactly the ones with no wagon a, then a
/// wagon smaller than a, then a wagon between the two: put another way,
/// they are the orders avoiding the pattern 3 1 2. Donald Knuth wrote
/// this down in 1968, in the first volume of The Art of Computer
/// Programming, and counted them: they are the Catalan numbers.
class Rules {
  /// The wagons, numbered 1 up in the order they stand.
  static const wagons = 6;

  /// What a tap does.
  static const shunt = 'shunt', roll = 'roll', send = 'send';

  /// Whether the out-train [train] can be made by one siding, found by
  /// running the yard: the first voice.
  static bool canBeRun(List<int> train) => tapsFor(train) != null;

  /// The taps the out-train takes, or null when the siding cannot make
  /// it. Nothing here is a choice: at every step the wanted wagon is
  /// either at the points or at the head of the line, or the head of
  /// the line has to be shunted out of the way.
  static int? tapsFor(List<int> train) {
    if (train.length != wagons) return null;
    final line = [for (var w = 1; w <= wagons; w++) w];
    final siding = <int>[];
    var taps = 0;
    for (final want in train) {
      while (true) {
        if (siding.isNotEmpty && siding.last == want) {
          siding.removeLast();
          taps++;
          break;
        }
        if (line.isNotEmpty && line.first == want) {
          line.removeAt(0);
          taps++;
          break;
        }
        if (line.isEmpty) return null;
        siding.add(line.removeAt(0));
        taps++;
      }
    }
    return taps;
  }

  /// The second voice, which never touches a yard: does the train hold
  /// a wagon, then a smaller one, then one in between?
  static bool holdsPattern(List<int> train) {
    for (var i = 0; i < train.length; i++) {
      for (var j = i + 1; j < train.length; j++) {
        for (var k = j + 1; k < train.length; k++) {
          if (train[j] < train[k] && train[k] < train[i]) return true;
        }
      }
    }
    return false;
  }

  /// Where the pattern sits, for the card to point at.
  static List<int>? pattern(List<int> train) {
    for (var i = 0; i < train.length; i++) {
      for (var j = i + 1; j < train.length; j++) {
        for (var k = j + 1; k < train.length; k++) {
          if (train[j] < train[k] && train[k] < train[i]) {
            return [train[i], train[j], train[k]];
          }
        }
      }
    }
    return null;
  }

  /// Every order of the wagons, in a settled order.
  static Iterable<List<int>> orders([int? many]) sync* {
    final n = many ?? wagons;
    final at = [for (var w = 1; w <= n; w++) w];
    yield List.of(at);
    while (true) {
      var i = n - 2;
      while (i >= 0 && at[i] >= at[i + 1]) {
        i--;
      }
      if (i < 0) return;
      var j = n - 1;
      while (at[j] <= at[i]) {
        j--;
      }
      final swap = at[i];
      at[i] = at[j];
      at[j] = swap;
      for (var a = i + 1, b = n - 1; a < b; a++, b--) {
        final held = at[a];
        at[a] = at[b];
        at[b] = held;
      }
      yield List.of(at);
    }
  }

  /// Every out-train one siding can make.
  static Iterable<List<int>> trains() sync* {
    for (final order in orders()) {
      if (canBeRun(order)) yield order;
    }
  }

  static int howManyOrders([int? many]) {
    var out = 1;
    for (var k = 2; k <= (many ?? wagons); k++) {
      out *= k;
    }
    return out;
  }

  static String tellTrain(List<int> train) => train.join(', ');
}
