import 'fewest.dart';
import 'land.dart';

/// A map part painted.
class Play {
  Play._(this.land, this.painting, this.dyes);

  factory Play.of(Land land, Painting painting) =>
      Play._(land, painting, List.filled(land.count, -1));

  final Land land;

  /// The answer, worked out when the map is opened.
  final Painting painting;

  /// A dye per field, or -1 for a field nobody has painted.
  final List<int> dyes;

  /// How many dyes are on offer: the fewest there are, and one more, so that
  /// somebody can finish a map the wrong way and be told.
  int get most => painting.fewest + 1;

  int get fewest => painting.fewest;

  int dyeOf(int field) => dyes[field];

  int get done => dyes.where((dye) => dye >= 0).length;

  bool get isFull => done == land.count;

  /// The dyes actually used, however many are on offer.
  Set<int> get used => dyes.where((dye) => dye >= 0).toSet();

  /// Every pair of fields that share a hedge and are painted the same.
  List<(int, int)> get clashes => [
        for (final (one, other) in land.hedges)
          if (dyes[one] >= 0 && dyes[one] == dyes[other]) (one, other),
      ];

  bool get isDone => isFull && clashes.isEmpty;

  bool get isFewest => isDone && used.length == fewest;

  Play paint(int field, int dye) {
    if (field < 0 || field >= land.count || dye < 0 || dye >= most) return this;
    final next = List.of(dyes);
    next[field] = next[field] == dye ? -1 : dye;
    return Play._(land, painting, next);
  }

  Play rub(int field) {
    if (field < 0 || field >= land.count || dyes[field] < 0) return this;
    final next = List.of(dyes);
    next[field] = -1;
    return Play._(land, painting, next);
  }

  Play get again => Play.of(land, painting);

  /// Whether what is painted so far can still be finished in the fewest dyes
  /// there are.
  ///
  /// The same search that found the answer, with the fields somebody has
  /// already painted held where they are. Once a field is fixed the dyes are
  /// no longer interchangeable, so this one has to try all of them on every
  /// field rather than only ever reaching for one new pot.
  bool get canStillDoIt => _finish(List.of(dyes)) != null;

  /// A field to paint next, and the dye to paint it, that still leaves the
  /// map finishable in the fewest there are.
  (int, int)? get next {
    final rest = _finish(List.of(dyes));
    if (rest == null) return null;
    for (var field = 0; field < land.count; field++) {
      if (dyes[field] < 0) return (field, rest[field]);
    }
    return null;
  }

  List<int>? _finish(List<int> so) {
    for (var field = 0; field < land.count; field++) {
      if (so[field] < fewest) continue;
      // A dye used that is not one of the fewest. Nothing can rescue that.
      return null;
    }
    for (final (one, other) in land.hedges) {
      if (so[one] >= 0 && so[one] == so[other]) return null;
    }

    bool paint(int field) {
      if (field == land.count) return true;
      if (so[field] >= 0) return paint(field + 1);
      for (var dye = 0; dye < fewest; dye++) {
        if (land.beside(field).any((other) => so[other] == dye)) continue;
        so[field] = dye;
        if (paint(field + 1)) return true;
        so[field] = -1;
      }
      return false;
    }

    return paint(0) ? so : null;
  }
}
