import 'rules.dart';

/// One ask: a train to gear on the pegboard.
class Level {
  const Level({
    required this.name,
    required this.width,
    required this.height,
    required this.fixed,
    required this.tray,
    required this.kind,
    required this.ways,
    required this.settings,
    required this.note,
  });

  final String name;
  final int width;
  final int height;

  /// The gears given: the crank first, turning clockwise, then the mill
  /// where the ask has one; (x, y, radius).
  final List<(int, int, int)> fixed;

  /// The radii of the gears in the tray, all to be placed.
  final List<int> tray;

  /// 'turns': the mill turns; 'against': the mill turns against the
  /// crank; 'twice': the mill turns twice a crank turn; 'ring': every
  /// gear turns and the crank is in a ring.
  final String kind;

  /// How many placings land it, and how many placings there are, from
  /// the sweep.
  final int ways;
  final int settings;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  bool get hasMill => fixed.length > 1;

  /// Whether the gears [all], the fixed first, land the ask.
  bool meets(List<(int, int, int)> all) {
    if (all.length != fixed.length + tray.length || !Rules.apart(all)) return false;
    final (way, jam) = Rules.turning(all, 0);
    switch (kind) {
      case 'turns':
        return !jam && way[1] != 0;
      case 'against':
        return !jam && way[1] == -1;
      case 'twice':
        return !jam && way[1] != 0 && Rules.speed(all[0], all[1]) == (2, 1);
      default:
        return !jam && Rules.inRing(all, 0) && way.every((x) => x != 0);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final told = tray.map(_told).toList();
    final gears = tray.length == 1 ? 'the gear of ${told.first}' : 'the gears of ${told.sublist(0, told.length - 1).join(', ')} and ${told.last}';
    switch (kind) {
      case 'turns':
        return 'set $gears so the crank turns the mill';
      case 'against':
        return 'set $gears so the mill turns against the crank';
      case 'twice':
        return 'set $gears so the mill turns twice for every turn of the crank';
      default:
        return 'set $gears round the crank in a ring that turns';
    }
  }

  static String _told(int r) => switch (r) { 1 => 'one', 2 => 'two', 3 => 'three', _ => '$r' };
}
