import 'quay.dart';

/// The most ships that can have the berth, and the reason there are no more.
class Berthing {
  const Berthing({required this.taken, required this.marks});

  /// The ships that get the berth.
  final List<int> taken;

  /// The hours that prove there are no more.
  ///
  /// Every ship in the day wants the berth at one of these hours, and two
  /// ships that want it at the same hour cannot both have it. So there cannot
  /// be more ships in the day than there are hours in this list, and there
  /// are exactly that many. It is a proof anybody can check with a finger.
  final List<int> marks;

  int get most => taken.length;
}

/// Works out the most ships that can be given the berth.
///
/// Take the ship that casts off earliest. Then, of the ships that do not clash
/// with it, take the one that casts off earliest, and keep going. That is the
/// whole method and it is exactly right, which is worth saying plainly because
/// the obvious alternatives are not: taking whoever comes alongside first is
/// wrong, and so is taking the shortest stay first.
///
/// It is right because of an exchange. Take any way of berthing the most ships
/// there are. The ship in it that casts off first cannot cast off earlier than
/// the ship this method takes first, so swapping this method's ship in for it
/// clashes with nothing that was there and leaves just as many ships berthed.
/// Do the same again on what is left. The answer this method gives is
/// therefore as good as the best one there is.
///
/// The proof of the number comes out of the same walk for nothing. Every ship
/// that is passed over is passed over because it clashes with the last ship
/// taken, which means it is still in the berth on that ship's last hour. So
/// the last hours of the ships taken are a set of hours that every ship in the
/// day wants, and no two ships wanting the same hour can both be berthed.
class Berthings {
  const Berthings._();

  static Berthing most(Quay quay, {Set<int>? only}) {
    final taken = <int>[];
    final marks = <int>[];
    var free = -1 << 20;

    for (final ship in quay.byCastingOff) {
      if (only != null && !only.contains(ship)) continue;
      if (quay[ship].from < free) continue;
      taken.add(ship);
      marks.add(quay[ship].lastHour);
      free = quay[ship].to;
    }

    return Berthing(taken: taken, marks: marks);
  }

  /// The same question answered by trying every set of ships there is.
  ///
  /// Slow and stupid on purpose. It is what holds the method above to account
  /// rather than anything the game runs.
  static int byTrying(Quay quay) {
    var best = 0;
    for (var set = 0; set < (1 << quay.count); set++) {
      final taken = [
        for (var ship = 0; ship < quay.count; ship++)
          if (set & (1 << ship) != 0) ship,
      ];
      if (taken.length <= best) continue;
      if (quay.allFit(taken)) best = taken.length;
    }
    return best;
  }

  /// What somebody gets by taking whoever comes alongside first, which is what
  /// a harbour master with no book would do.
  static List<int> byArriving(Quay quay) {
    final order = [for (var ship = 0; ship < quay.count; ship++) ship];
    order.sort((one, other) {
      final by = quay[one].from.compareTo(quay[other].from);
      return by != 0 ? by : one.compareTo(other);
    });

    final taken = <int>[];
    var free = -1 << 20;
    for (final ship in order) {
      if (quay[ship].from < free) continue;
      taken.add(ship);
      free = quay[ship].to;
    }
    return taken;
  }

  /// And by taking the shortest stay first, which is the other thing people
  /// try.
  static List<int> byShortest(Quay quay) {
    final order = [for (var ship = 0; ship < quay.count; ship++) ship];
    order.sort((one, other) {
      final by = quay[one].hours.compareTo(quay[other].hours);
      return by != 0 ? by : one.compareTo(other);
    });

    final taken = <int>[];
    for (final ship in order) {
      if (taken.any((other) => quay.clash(ship, other))) continue;
      taken.add(ship);
    }
    return taken;
  }
}
