/// The law of the lawn.
///
/// Guests stand on a lawn, and handshakes pass guest to guest. A
/// guest who has shaken an odd number of hands is odd-handed.
///
/// The handshake lemma is the law: the odd-handed always number
/// even, because every shake hands out exactly two. It is
/// checked more ways than one: the census counts each guest's
/// hands; the doubling holds the hand-total to twice the shakes
/// on every lawn the sweep lays; the sweep itself counts the
/// lawns landing each asking; and the all-even lawns come to a
/// power of two, two to the shakes beyond a spanning tree. The
/// suite refuses the bake the moment any two part ways.
class Rules {
  Rules(this.guests);

  final int guests;

  /// Every handshake the lawn could see.
  List<(int, int)> get allShakes => [
        for (var a = 0; a < guests; a++)
          for (var b = a + 1; b < guests; b++) (a, b),
      ];

  /// How many hands each guest has shaken.
  List<int> hands(List<(int, int)> shakes) {
    final shaken = List.filled(guests, 0);
    for (final (a, b) in shakes) {
      shaken[a]++;
      shaken[b]++;
    }
    return shaken;
  }

  /// The odd-handed guests.
  List<int> oddHanded(List<(int, int)> shakes) {
    final shaken = hands(shakes);
    return [
      for (var at = 0; at < guests; at++)
        if (shaken[at].isOdd) at,
    ];
  }

  /// Every lawn of any number of shakes, walked; calls [visit]
  /// with each. The sweep the checker and the suite share.
  void lawns(void Function(List<(int, int)>) visit) {
    final shakes = allShakes;
    final picked = <(int, int)>[];
    void walk(int at) {
      if (at == shakes.length) {
        visit(picked);
        return;
      }
      walk(at + 1);
      picked.add(shakes[at]);
      walk(at + 1);
      picked.removeLast();
    }

    walk(0);
  }

  /// How many lawns keep exactly [odd] odd-handed guests.
  int waysTo(int odd) {
    var count = 0;
    lawns((shakes) {
      if (oddHanded(shakes).length == odd) count++;
    });
    return count;
  }

  /// One lawn keeping exactly [odd] odd-handed guests with as
  /// many shakes as [most] allows, or null.
  List<(int, int)>? lawn(int odd) {
    List<(int, int)>? found;
    lawns((shakes) {
      if (found == null && oddHanded(shakes).length == odd) {
        // Prefer a lawn with some shakes on it, for the showing.
        if (shakes.isNotEmpty || odd == 0) {
          found ??= List.of(shakes);
        }
      }
    });
    return found;
  }

  /// One lawn with shakes on it landing [odd], or null: better
  /// for pointing than the empty lawn.
  List<(int, int)>? busyLawn(int odd) {
    List<(int, int)>? found;
    lawns((shakes) {
      if (found == null &&
          shakes.isNotEmpty &&
          oddHanded(shakes).length == odd) {
        found = List.of(shakes);
      }
    });
    return found ?? lawn(odd);
  }

  /// Whether the law holds over the whole sweep: hands double
  /// the shakes, and the odd-handed count is never odd.
  bool lawHolds() {
    var sound = true;
    lawns((shakes) {
      final shaken = hands(shakes);
      final total = shaken.fold(0, (a, b) => a + b);
      if (total != 2 * shakes.length) sound = false;
      if (oddHanded(shakes).length.isOdd) sound = false;
    });
    return sound;
  }
}
