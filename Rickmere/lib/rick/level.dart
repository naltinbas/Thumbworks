import 'rules.dart';

/// One ask: what the field is to be.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// 'square': the field has a square corner; 'six': the field is six
  /// acres; 'squaresix': both; 'widest': the ricks stand as far apart
  /// as the green allows; 'uneven': the three markers are not evenly
  /// spread, which never happens.
  final String kind;

  /// How many fields land it, from the sweep.
  final int ways;

  /// The fewest posts to move from the opening; null when no field
  /// lands it.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the field lands the ask.
  bool meets(List<(int, int)> posts) {
    if (!Rules.isField(posts)) return false;
    switch (kind) {
      case 'square':
        return Rules.squareCorner(posts);
      case 'six':
        return Rules.halfAcres(posts) == 12;
      case 'squaresix':
        return Rules.squareCorner(posts) && Rules.halfAcres(posts) == 12;
      case 'widest':
        return Rules.markerSides(posts).first == Rules.widest;
      default:
        return !Rules.evenByLength(posts);
    }
  }

  /// The task, told in words.
  String get task => switch (kind) {
        'square' => 'stand the posts so the field has a square corner',
        'six' => 'stand the posts so the field is six acres',
        'squaresix' => 'stand the posts so the field has a square corner and '
            'is six acres',
        'widest' => 'stand the posts so the rick markers stand as far apart '
            'as the green allows',
        _ => 'stand the posts so the three rick markers are not evenly spread',
      };
}
