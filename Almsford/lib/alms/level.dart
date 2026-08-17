import 'rules.dart';

/// One ask: what shape the bins are to stand in when the sharing is
/// done.
class Level {
  const Level({
    required this.name,
    required this.shape,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The heights the ask wants, tallest first.
  final List<int> shape;

  /// How many arrangements of the bins stand in that shape.
  final int ways;

  /// The fewest shares it takes from the opening; null when the shape
  /// cannot be reached at all.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => fewest != null;

  /// Whether the bins stand in the shape the ask wants.
  bool meets(List<int> bins) =>
      Rules.shape(bins).join(',') == shape.join(',');

  /// The task, told in words.
  String get task =>
      'share the grain out until the bins stand ${Rules.tellShape(shape)}';
}
