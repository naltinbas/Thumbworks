/// The law of the sash.
///
/// Panes sit in the lights of a sash, so many across and so many
/// down. A window is four panes on the corners of an upright
/// rectangle: two columns sharing two rows. The glazier's rule is
/// to set panes without ever framing one.
///
/// How many panes a sash can take is checked two ways that share
/// nothing: windows counted down the columns and again across the
/// rows, held equal over every placing the sweep lays, and an
/// arithmetic floor besides, since a sash of four rows owns only
/// six row-pairs and every column of c panes spends C(c, 2) of
/// them. The suite refuses the bake the moment any two part ways.
class Rules {
  Rules(this.across, this.down);

  /// Lights across and down the sash.
  final int across;
  final int down;

  List<(int, int)> get lights => [
        for (var x = 0; x < across; x++)
          for (var y = 0; y < down; y++) (x, y),
      ];

  /// Every window framed by the panes: two columns sharing two
  /// rows, counted down the columns.
  List<((int, int), (int, int), (int, int), (int, int))> windows(
      List<(int, int)> panes) {
    final framed =
        <((int, int), (int, int), (int, int), (int, int))>[];
    for (var a = 0; a < across; a++) {
      for (var b = a + 1; b < across; b++) {
        final shared = [
          for (var y = 0; y < down; y++)
            if (panes.contains((a, y)) && panes.contains((b, y))) y,
        ];
        for (var s = 0; s < shared.length; s++) {
          for (var t = s + 1; t < shared.length; t++) {
            framed.add((
              (a, shared[s]),
              (b, shared[s]),
              (a, shared[t]),
              (b, shared[t]),
            ));
          }
        }
      }
    }
    return framed;
  }

  /// Windows counted down the columns.
  int windowsByColumns(List<(int, int)> panes) =>
      windows(panes).length;

  /// Windows counted the other way: for every pair of rows, the
  /// columns holding both, and C(shared, 2) windows between them.
  int windowsByRows(List<(int, int)> panes) {
    var framed = 0;
    for (var s = 0; s < down; s++) {
      for (var t = s + 1; t < down; t++) {
        var shared = 0;
        for (var x = 0; x < across; x++) {
          if (panes.contains((x, s)) && panes.contains((x, t))) {
            shared++;
          }
        }
        framed += shared * (shared - 1) ~/ 2;
      }
    }
    return framed;
  }

  bool windowFree(List<(int, int)> panes) =>
      windowsByColumns(panes) == 0;

  /// The row-pairs a placing spends, column by column: each column
  /// of c panes uses C(c, 2), and no two columns may spend the
  /// same pair when the sash is window-free.
  int rowPairsSpent(List<(int, int)> panes) {
    var spent = 0;
    for (var x = 0; x < across; x++) {
      final held = panes.where((pane) => pane.$1 == x).length;
      spent += held * (held - 1) ~/ 2;
    }
    return spent;
  }

  /// The row-pairs the sash owns: C(down, 2).
  int get rowPairs => down * (down - 1) ~/ 2;

  /// The fewest row-pairs [count] panes can spend on this sash,
  /// walked over every split of the count across the columns.
  int fewestSpend(int count) {
    var fewest = 1 << 30;
    void walk(int column, int left, int spent) {
      if (spent >= fewest) return;
      if (column == across) {
        if (left == 0 && spent < fewest) fewest = spent;
        return;
      }
      for (var held = 0; held <= down && held <= left; held++) {
        walk(column + 1, left - held,
            spent + held * (held - 1) ~/ 2);
      }
    }

    walk(0, count, 0);
    return fewest;
  }

  /// Every placing of [count] panes, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void placings(int count, void Function(List<(int, int)>) visit) {
    final spots = lights;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < spots.length; at++) {
        picked.add(spots[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many placings of [count] panes frame no window.
  int waysTo(int count) {
    var ways = 0;
    placings(count, (panes) {
      if (windowFree(panes)) ways++;
    });
    return ways;
  }

  /// The two window counts held together over every placing of
  /// [count] panes: true when nothing breaks.
  bool countsAgree(int count) {
    var sound = true;
    placings(count, (panes) {
      if (windowsByColumns(panes) != windowsByRows(panes)) {
        sound = false;
      }
    });
    return sound;
  }
}
