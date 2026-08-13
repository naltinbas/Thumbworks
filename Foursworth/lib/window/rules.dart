/// The law of the house.
///
/// Windows round a house, each showing nought to seven, and
/// one turn: every window takes the difference to its
/// neighbour, all at once, round the ring. Ducci's walk. Four
/// windows always go dark, by the seventh turn at the latest,
/// since four turns leave every number even and evens halve to
/// a smaller game; three windows circle for ever unless they
/// start all alike, their parities treading a three-cycle that
/// never lands.
class Rules {
  /// The highest face a window shows.
  static const brightest = 7;

  /// One turn of the house.
  static List<int> turn(List<int> windows) => [
        for (var at = 0; at < windows.length; at++)
          (windows[at] - windows[(at + 1) % windows.length]).abs(),
      ];

  /// Whether every window is dark.
  static bool dark(List<int> windows) =>
      windows.every((face) => face == 0);

  /// The walk from a dialling to darkness, the dialling first;
  /// cut off past forty turns, which only the circling reach.
  static List<List<int>> walk(List<int> windows) {
    final steps = [List.of(windows)];
    var at = List.of(windows);
    while (!dark(at) && steps.length <= 40) {
      at = turn(at);
      steps.add(at);
    }
    return steps;
  }

  /// How many turns to darkness; -1 for the circling.
  static int turnsToDark(List<int> windows) {
    final road = walk(windows);
    return dark(road.last) ? road.length - 1 : -1;
  }

  /// Every dialling of [count] windows, walked; calls [visit].
  static void diallings(
      int count, void Function(List<int>) visit) {
    final windows = List.filled(count, 0);
    void dial(int at) {
      if (at == count) {
        visit(windows);
        return;
      }
      for (var face = 0; face <= brightest; face++) {
        windows[at] = face;
        dial(at + 1);
      }
    }

    dial(0);
  }

  /// How many diallings of [count] windows go dark in exactly
  /// [asked] turns.
  static int waysTo(int count, int asked) {
    var ways = 0;
    diallings(count, (windows) {
      if (turnsToDark(windows) == asked) ways++;
    });
    return ways;
  }

  /// The laws over every dialling: four windows rest by seven
  /// with all-even after four turns, and three windows rest
  /// exactly when they start all alike, in one turn or none.
  static bool lawsHold() {
    var sound = true;
    diallings(4, (windows) {
      final turns = turnsToDark(windows);
      if (turns < 0 || turns > 7) sound = false;
      var at = List.of(windows);
      for (var step = 0; step < 4; step++) {
        at = turn(at);
      }
      if (at.any((face) => face.isOdd)) sound = false;
    });
    diallings(3, (windows) {
      final alike = windows.toSet().length == 1;
      final turns = turnsToDark(windows);
      if (alike != (turns >= 0)) sound = false;
      if (alike && !dark(windows) && turns != 1) sound = false;
    });
    return sound;
  }
}
