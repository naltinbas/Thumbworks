/// One task on the green: what the binder of sheep wants penned.
class Green {
  const Green({
    required this.name,
    required this.size,
    this.area2,
    this.penned,
    this.thirds,
    required this.posts,
    this.ways,
    this.note,
  });

  final String name;

  /// Crossings along each side of the green.
  final int size;

  /// Twice the acreage asked for, or null for no asking.
  final int? area2;

  /// Crossings to pen exactly, or null for no asking.
  final int? penned;

  /// An acreage asked in thirds of an acre, or null. No fence meets
  /// one: twice any fence's acreage is a whole number.
  final int? thirds;

  /// Fewest hurdles any fence that settles this needs; null when no
  /// fence at all does, and the label says so.
  final int? posts;

  /// How many fences of four hurdles or fewer settle it, from the
  /// sweep; null on the hopeless green.
  final int? ways;

  /// One thing worth knowing about this green, said by the why.
  final String? note;

  bool get winnable => posts != null;

  /// The task, told in words for the ledger.
  String get task {
    if (thirds != null) {
      return 'pen a third of an acre';
    }
    final wants = <String>[];
    final twice = area2;
    if (twice != null) {
      wants.add('pen ${acres(twice)}');
    }
    final sheep = penned;
    if (sheep != null) {
      wants.add(sheep == 0
          ? 'swallow nothing'
          : twice == null
              ? 'swallow $sheep crossing${sheep == 1 ? '' : 's'} exactly'
              : 'swallow $sheep crossing${sheep == 1 ? '' : 's'}');
    }
    return wants.join(' and ');
  }

  /// Acreage in words, from twice its count.
  static String acres(int twice) {
    if (twice == 1) return 'half an acre';
    if (twice == 2) return 'an acre';
    if (twice.isEven) return '${twice ~/ 2} acres';
    return '${twice ~/ 2} acres and a half';
  }
}
