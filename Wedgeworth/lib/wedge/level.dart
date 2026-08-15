import 'rules.dart';

/// One ask: a corner to close, of given faces or a given solid.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.sides,
    this.faceCount,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'faces' asks for a closed corner of [sides]-sided faces; 'solid'
  /// asks for a closed corner whose solid has [faceCount] faces.
  final String kind;

  final int? sides;
  final int? faceCount;

  /// How many of the settings on the sham land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  /// The settings on the sham.
  int get settings => Rules.sides.length * Rules.faces.length;

  bool get winnable => ways > 0;

  /// Whether the corner of q faces of p sides lands the ask.
  bool meets(int p, int q) {
    if (!Rules.closes(p, q)) return false;
    if (kind == 'faces') return p == sides;
    return Rules.euler(p, q)!.$3 == faceCount;
  }

  /// The task, told in words for the ledger.
  String get task => kind == 'faces'
      ? 'close a corner of ${Rules.face(sides!, plural: true)}'
      : 'close a corner whose solid has ${_told(faceCount!)} faces';

  static String _told(int n) => switch (n) {
        4 => 'four',
        6 => 'six',
        8 => 'eight',
        12 => 'twelve',
        20 => 'twenty',
        _ => '$n',
      };
}
