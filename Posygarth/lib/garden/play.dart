import 'garth.dart';
import 'rules.dart';

/// A garth part planted: what stands in every bed.
class Play {
  const Play._(this.garth, this.beds, this.before);

  factory Play.of(Garth garth) {
    final beds = List<(int, int)>.filled(garth.beds, (-1, -1));
    for (final (bed, flower, colour) in garth.seeded) {
      beds[bed] = (flower, colour);
    }
    return Play._(garth, List.unmodifiable(beds), null);
  }

  final Garth garth;

  /// (flower, colour) by row-major bed, (-1, -1) while empty.
  final List<(int, int)> beds;

  /// The garth before the last planting, or null at the start.
  final Play? before;

  int get planted => beds.where((bed) => bed.$1 >= 0).length;

  bool get isBloomed => planted == garth.beds;

  bool isEmpty(int bed) => beds[bed].$1 < 0;

  bool isSeeded(int bed) {
    for (final (seeded, _, _) in garth.seeded) {
      if (seeded == bed) return true;
    }
    return false;
  }

  /// What forbids a posy at a bed, in words, or null when it fits.
  String? clashAt(int bed, int flower, int colour) {
    final size = garth.size;
    final row = bed ~/ size, column = bed % size;
    for (var at = 0; at < size; at++) {
      final inRow = beds[row * size + at];
      if (at != column && inRow.$1 >= 0) {
        if (inRow.$1 == flower) return 'that flower is in this row';
        if (inRow.$2 == colour) return 'that colour is in this row';
      }
      final inCol = beds[at * size + column];
      if (at != row && inCol.$1 >= 0) {
        if (inCol.$1 == flower) return 'that flower is in this column';
        if (inCol.$2 == colour) return 'that colour is in this column';
      }
    }
    for (final (f, c) in beds) {
      if (f == flower && c == colour) {
        return 'that very posy is planted already';
      }
    }
    return null;
  }

  /// Plants a posy. Returns this unchanged when it cannot go in.
  Play plant(int bed, int flower, int colour) {
    if (bed < 0 || bed >= garth.beds || !isEmpty(bed)) return this;
    if (clashAt(bed, flower, colour) != null) return this;
    return Play._(
      garth,
      List.unmodifiable([
        for (var at = 0; at < garth.beds; at++)
          at == bed ? (flower, colour) : beds[at],
      ]),
      this,
    );
  }

  /// The last posy dug up again, or this at the start.
  Play get back => before ?? this;

  /// Whether the garth can still bloom from here.
  bool get canStill => Rules.canStillPlant(garth.size, [...beds]);

  /// A planting that keeps the garth bloomable, as (bed, flower,
  /// colour), or null.
  (int, int, int)? get next {
    if (isBloomed || !canStill) return null;
    for (var bed = 0; bed < garth.beds; bed++) {
      if (!isEmpty(bed)) continue;
      for (var flower = 0; flower < garth.size; flower++) {
        for (var colour = 0; colour < garth.size; colour++) {
          if (clashAt(bed, flower, colour) != null) continue;
          final tried = plant(bed, flower, colour);
          if (Rules.canStillPlant(garth.size, [...tried.beds])) {
            return (bed, flower, colour);
          }
        }
      }
      return null;
    }
    return null;
  }
}
