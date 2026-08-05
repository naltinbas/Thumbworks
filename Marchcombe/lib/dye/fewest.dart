import 'land.dart';

/// The fewest dyes a map can be painted in, and the reason it cannot be
/// fewer.
class Painting {
  const Painting({
    required this.fewest,
    required this.dyes,
    required this.ring,
    required this.tried,
  });

  /// How many dyes it takes.
  final int fewest;

  /// One way of painting it in that many, a dye per field.
  final List<int> dyes;

  /// A set of fields that all share a hedge with each other. Every one of them
  /// needs a dye of its own, so the map cannot be painted in fewer than there
  /// are fields in here. When it is as long as [fewest], the map carries its
  /// own proof and a player can check it by looking.
  final List<int> ring;

  /// How many part-paintings had to be looked at.
  final int tried;

  bool get ringSaysSo => ring.length == fewest;
}

/// Works out the fewest dyes a map can be painted in.
///
/// Two ways, because one way is a claim.
///
/// [paint] tries every painting there is, in one dye first, then two, and so
/// on, and the first number that works is the answer. It never gives a field
/// a dye that a field it shares a hedge with already has, and it never uses a
/// new dye before it has tried the ones already out, which is what keeps it
/// from painting the same map over again with the dyes swapped round.
///
/// [byCovering] asks a different question that has the same answer: what is
/// the fewest sets of fields, none of which touch each other, that the whole
/// map can be split into? Fields painted the same dye never touch, so a
/// painting in k dyes is a split into k such sets and the other way round.
/// It works over sets of fields rather than over paintings and shares nothing
/// with the first method but the map.
class Dyes {
  const Dyes._();

  static Painting fewestFor(Land land) {
    final ring = biggestRing(land);
    for (var many = ring.length.clamp(1, land.count); many <= land.count;
        many++) {
      final found = _inThisMany(land, many);
      if (found != null) {
        return Painting(
          fewest: many,
          dyes: found.$1,
          ring: ring,
          tried: found.$2,
        );
      }
    }
    return Painting(
      fewest: land.count,
      dyes: [for (var field = 0; field < land.count; field++) field],
      ring: ring,
      tried: 0,
    );
  }

  /// A painting in exactly this many dyes, and how many part-paintings were
  /// looked at on the way, or null.
  static (List<int>, int)? _inThisMany(Land land, int many) {
    final dyes = List.filled(land.count, -1);
    var tried = 0;

    bool paint(int field, int out) {
      if (field == land.count) return true;
      tried++;

      // Only ever one new dye at a time. Two paintings that differ by which
      // pot a dye came out of are the same painting.
      final most = out + 1 > many ? many : out + 1;
      for (var dye = 0; dye < most; dye++) {
        if (land.beside(field).any((other) => dyes[other] == dye)) continue;
        dyes[field] = dye;
        if (paint(field + 1, dye + 1 > out ? dye + 1 : out)) return true;
        dyes[field] = -1;
      }
      return false;
    }

    return paint(0, 0) ? (List.of(dyes), tried) : null;
  }

  /// The same answer, worked out by splitting the map into sets of fields that
  /// do not touch each other.
  ///
  /// Every set of fields is either one where no two of them share a hedge or
  /// not; the answer for a set of fields is one more than the best answer for
  /// what is left after taking one of those out of it. Working through the
  /// sets from small to large fills that in for every set on the map, and the
  /// answer for the whole map is the last one written down.
  static int byCovering(Land land) {
    final whole = (1 << land.count) - 1;
    if (whole == 0) return 0;

    final beside = [
      for (var field = 0; field < land.count; field++)
        land.beside(field).fold(0, (bits, other) => bits | (1 << other)),
    ];

    // Whether the fields in a set all keep out of each other's way.
    final apart = List.filled(whole + 1, false);
    for (var set = 0; set <= whole; set++) {
      var fine = true;
      for (var field = 0; field < land.count && fine; field++) {
        if (set & (1 << field) == 0) continue;
        if (beside[field] & set != 0) fine = false;
      }
      apart[set] = fine;
    }

    final needs = List.filled(whole + 1, land.count + 1);
    needs[0] = 0;
    for (var set = 1; set <= whole; set++) {
      // Walk the subsets of this set, which is the standard way round: take
      // one away at a time and mask.
      for (var part = set; part > 0; part = (part - 1) & set) {
        if (!apart[part]) continue;
        final rest = needs[set ^ part];
        if (rest + 1 < needs[set]) needs[set] = rest + 1;
      }
    }
    return needs[whole];
  }

  /// The biggest set of fields that all share a hedge with each other.
  ///
  /// Every one of them has to be a different dye from every other, so the map
  /// cannot be done in fewer dyes than this has fields. It is a proof anybody
  /// can check by looking at the map, which is why the game shows it rather
  /// than saying take my word for it.
  static List<int> biggestRing(Land land) {
    var best = <int>[];

    void grow(List<int> ring, int from) {
      if (ring.length > best.length) best = List.of(ring);
      for (var field = from; field < land.count; field++) {
        if (ring.any((other) => !land.touches(field, other))) continue;
        ring.add(field);
        grow(ring, field + 1);
        ring.removeLast();
      }
    }

    grow(<int>[], 0);
    return best;
  }

  /// How many different paintings there are in exactly this many dyes, with
  /// the dyes told apart.
  static int ways(Land land, int many) {
    final dyes = List.filled(land.count, -1);
    var found = 0;

    void paint(int field) {
      if (field == land.count) {
        found++;
        return;
      }
      for (var dye = 0; dye < many; dye++) {
        if (land.beside(field).any((other) => dyes[other] == dye)) continue;
        dyes[field] = dye;
        paint(field + 1);
        dyes[field] = -1;
      }
    }

    paint(0);
    return found;
  }

  /// What somebody gets by painting the fields in the order they are written
  /// down, each in the first dye none of its neighbours has. It is the obvious
  /// way and it is not always the answer.
  static List<int> byOrder(Land land) {
    final dyes = List.filled(land.count, -1);
    for (var field = 0; field < land.count; field++) {
      var dye = 0;
      while (land.beside(field).any((other) => dyes[other] == dye)) {
        dye++;
      }
      dyes[field] = dye;
    }
    return dyes;
  }
}
