import 'rules.dart';

/// One ask: stickers and packets to set.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'sixMedian': six stickers, and the fewest packets that make the
  /// album more likely full than not; 'twelveLikely': twelve stickers
  /// and packets enough to make it more likely full than not; 'whole':
  /// the average packets a whole number; 'last': the last sticker alone
  /// takes longer on average than the rest together; 'certain': two
  /// stickers or more and the album certain full.
  final String kind;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (stickers, packets), or null.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int stickers, int packets) {
    switch (kind) {
      case 'sixMedian':
        return stickers == 6 && Rules.fullAfter(6, packets).compareTo(Frac.of(1, 2)) >= 0 && (packets == 1 || Rules.fullAfter(6, packets - 1).compareTo(Frac.of(1, 2)) < 0);
      case 'twelveLikely':
        return stickers == 12 && Rules.fullAfter(12, packets).compareTo(Frac.of(1, 2)) >= 0;
      case 'whole':
        return Rules.averageByStages(stickers).isWhole;
      case 'last':
        return Frac.of(stickers).compareTo(Rules.averageByStages(stickers) - Frac.of(stickers)) > 0;
      default:
        return stickers >= 2 && Rules.fullAfter(stickers, packets) == Frac.one;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'sixMedian':
        return 'set six stickers and the fewest packets that make the album more likely full than not';
      case 'twelveLikely':
        return 'set twelve stickers and packets enough to make the album more likely full than not';
      case 'whole':
        return 'set the stickers so the average packets to fill the album is a whole number';
      case 'last':
        return 'set the stickers so the last sticker alone takes longer, on average, than all the rest together';
      default:
        return 'set the stickers, two or more, and packets enough to make the album certain to be full';
    }
  }
}
