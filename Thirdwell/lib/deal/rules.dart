/// The law of the deal.
///
/// Twenty-seven counters in a stack, one of them yours. Deal them
/// out into three columns, first counter to the first column,
/// second to the second, round and round; say which column holds
/// yours; gather the columns into a stack again with yours on top,
/// in the middle, or at the bottom, as you please. Do it three
/// times. Gergonne worked out in 1813 where your counter ends up:
/// count the three placings as digits in threes, first deal the
/// units, and that is its place from the top, whatever place it
/// started in. Every place can be reached, each by one run of
/// placings only. Two deals cannot do it: after two, the counter's
/// place is three times a choice plus nine times a choice plus
/// its starting place counted in nines, so its units are fixed.
class Rules {
  Rules({this.deals = 3});

  /// How many deals the run allows.
  final int deals;

  static const counters = 27;

  /// The three columns a stack deals into, top to bottom each,
  /// the first counter to the first column and so on round.
  static List<List<int>> dealOut(List<int> stack) {
    final columns = [<int>[], <int>[], <int>[]];
    for (var i = 0; i < stack.length; i++) {
      columns[i % 3].add(stack[i]);
    }
    return columns;
  }

  /// The stack the columns make when gathered with the column
  /// holding [chosen] put at [placing], 0 top, 1 middle, 2 bottom,
  /// the other two keeping their order.
  static List<int> gather(List<List<int>> columns, int chosen, int placing) {
    final holding = columns.indexWhere((c) => c.contains(chosen));
    final others = [for (var i = 0; i < 3; i++) if (i != holding) columns[i]];
    final order = <List<int>?>[null, null, null];
    order[placing] = columns[holding];
    var k = 0;
    for (var i = 0; i < 3; i++) {
      order[i] ??= others[k++];
    }
    return [for (final column in order) ...column!];
  }

  /// The stack after a run of placings, from the counters in
  /// order nought to twenty-six.
  static List<int> run(int chosen, List<int> placings) {
    var stack = [for (var i = 0; i < counters; i++) i];
    for (final placing in placings) {
      stack = gather(dealOut(stack), chosen, placing);
    }
    return stack;
  }

  /// Where the chosen counter ends, nought from the top, after a
  /// run of placings, by dealing it out.
  static int placeBySimulation(int chosen, List<int> placings) =>
      run(chosen, placings).indexOf(chosen);

  /// Where it ends by Gergonne's arithmetic: the placings read as
  /// digits in threes, the first deal the units. Only whole for a
  /// run of three deals.
  static int? placeByArithmetic(List<int> placings) {
    if (placings.length != 3) return null;
    return placings[0] + 3 * placings[1] + 9 * placings[2];
  }

  /// The three placings that walk any counter to [place], by the
  /// same arithmetic backwards.
  static List<int> placingsFor(int place) =>
      [place % 3, (place ~/ 3) % 3, place ~/ 9];

  /// Every run of [deals] placings, walked; calls [visit].
  void runs(void Function(List<int>) visit) {
    final placings = <int>[];
    void pick() {
      if (placings.length == deals) {
        visit(placings);
        return;
      }
      for (var p = 0; p < 3; p++) {
        placings.add(p);
        pick();
        placings.removeLast();
      }
    }

    pick();
  }

  /// How many runs of [deals] placings land [chosen] at [place].
  int waysBySweep(int chosen, int place) {
    var ways = 0;
    runs((placings) {
      if (placeBySimulation(chosen, placings) == place) ways++;
    });
    return ways;
  }

  /// The places a counter can reach in [deals] deals, sorted.
  List<int> reachable(int chosen) {
    final places = <int>{};
    runs((placings) => places.add(placeBySimulation(chosen, placings)));
    return places.toList()..sort();
  }

  /// The first run of placings the sweep finds landing [chosen] at
  /// [place], or null.
  List<int>? landing(int chosen, int place) {
    List<int>? found;
    runs((placings) {
      if (found == null && placeBySimulation(chosen, placings) == place) {
        found = List.of(placings);
      }
    });
    return found;
  }
}
