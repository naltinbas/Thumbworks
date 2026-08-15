import 'rules.dart';

/// One hexagon on the sham: its sides, its chips, and what the sweeps
/// found.
class Level {
  const Level({
    required this.name,
    required this.a,
    required this.b,
    required this.c,
    this.chipped = const [],
    required this.ways,
    this.note,
  });

  final String name;
  final int a;
  final int b;
  final int c;

  /// Triangles taken out of the hexagon.
  final List<Tri> chipped;

  /// Tilings, by the sweep; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this hexagon, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Hexagon get hexagon => Hexagon(a, b, c, chipped: chipped);

  /// The task, told in words for the ledger.
  String get task => chipped.isEmpty
      ? 'tile the hexagon of sides $a, $b and $c with lozenges'
      : 'tile the hexagon of sides $a, $b and $c with lozenges, ${chipped.length} triangles chipped out';
}
