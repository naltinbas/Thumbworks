/// The law of the bunting.
///
/// Posts on a green, strings of bunting between them, and a
/// pot of inks. A string wears one ink, and two strings
/// sharing a post must never share an ink. Two inks serve any
/// path and any even ring; the odd ring refuses them, since
/// two inks can only alternate and an odd ring comes home
/// wrong; and the full four takes three inks exactly, its ink
/// classes always the three perfect matchings.
class Rules {
  Rules(this.posts, this.strings);

  final int posts;

  /// Every string, as a pair of posts.
  final List<(int, int)> strings;

  /// Which strings share a post with which, by index.
  List<List<int>> get beside => [
        for (var one = 0; one < strings.length; one++)
          [
            for (var two = 0; two < strings.length; two++)
              if (two != one &&
                  (strings[one].$1 == strings[two].$1 ||
                      strings[one].$1 == strings[two].$2 ||
                      strings[one].$2 == strings[two].$1 ||
                      strings[one].$2 == strings[two].$2))
                two,
          ],
      ];

  /// The clashes of an inking: pairs of neighbouring strings
  /// wearing the same ink, bare strings clashing with nobody.
  List<(int, int)> clashes(List<int> inks) {
    final near = beside;
    return [
      for (var one = 0; one < strings.length; one++)
        for (final two in near[one])
          if (two > one && inks[one] != 0 && inks[one] == inks[two])
            (one, two),
    ];
  }

  /// Whether an inking lands: every string inked, no clashes.
  bool lands(List<int> inks) =>
      inks.every((ink) => ink != 0) && clashes(inks).isEmpty;

  /// Every inking in [pot] inks, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void inkings(int pot, void Function(List<int>) visit) {
    final inks = List.filled(strings.length, 1);
    void dip(int from) {
      if (from == strings.length) {
        visit(inks);
        return;
      }
      for (var ink = 1; ink <= pot; ink++) {
        inks[from] = ink;
        dip(from + 1);
      }
    }

    dip(0);
  }

  /// How many inkings of [pot] inks land.
  int waysTo(int pot) {
    var ways = 0;
    inkings(pot, (inks) {
      if (lands(inks)) ways++;
    });
    return ways;
  }

  /// One landing inking of [pot] inks, or null: drives the
  /// show-me.
  List<int>? landing(int pot) {
    List<int>? found;
    inkings(pot, (inks) {
      if (found == null && lands(inks)) found = List.of(inks);
    });
    return found;
  }

  /// Whether every landing of [pot] inks splits the strings
  /// into perfect matchings, one per ink used: the full four's
  /// law.
  bool matchingsHold(int pot) {
    var sound = true;
    inkings(pot, (inks) {
      if (!lands(inks)) return;
      for (var ink = 1; ink <= pot; ink++) {
        final worn = [
          for (var at = 0; at < strings.length; at++)
            if (inks[at] == ink) at,
        ];
        final covered = <int>{};
        for (final at in worn) {
          covered.addAll([strings[at].$1, strings[at].$2]);
        }
        if (covered.length != 2 * worn.length) sound = false;
        if (worn.isNotEmpty && covered.length != posts) {
          sound = false;
        }
      }
    });
    return sound;
  }
}
