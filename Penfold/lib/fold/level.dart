import 'rules.dart';

/// One ask: which fold the sheep are in, and how long the call has to
/// be.
class Level {
  const Level({
    required this.name,
    required this.fold,
    required this.length,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The fold's name, which is its key in [Rules.folds].
  final String fold;

  /// The fewest whistles that gather the flock, or zero when nothing
  /// does.
  final int length;

  /// How many calls of that length gather the flock, from the sweep.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  List<List<int>> get whistles => Rules.folds[fold]!;

  /// Whether the flock has been gathered.
  bool meets(int flock) => winnable && Rules.gathered(flock);

  /// The fewest whistles from the flock as it starts.
  int? get fewest => Rules.fewest(whistles);

  /// How many calls of [length] there are at all.
  int get calls => 1 << length;

  /// The task, told in words for the ledger.
  String get task => winnable
      ? 'gather the flock in $fold, which takes $length whistles'
      : 'gather the flock in $fold';
}
