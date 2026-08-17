import 'frac.dart';
import 'rules.dart';

/// One ask: what the shares are to do.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'half': some lane takes exactly half the stringings; 'even':
  /// every lane takes the same share and none of them all of it;
  /// 'twohalves': two lanes or more at a half; 'full': every lane
  /// laid; 'more': the shares add to something other than four, which
  /// never happens.
  final String kind;

  /// How many villages land it, from the sweep.
  final int ways;

  /// The cheapest village that lands it, as lanes; null when none
  /// does.
  final List<int>? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  static final _half = Frac.of(1, 2);

  /// Whether the village lands the ask.
  bool meets(int mask) {
    if (!Rules.joinedUp(mask)) return false;
    final shares = Rules.shares(mask);
    switch (kind) {
      case 'half':
        return shares.values.any((share) => share == _half);
      case 'even':
        final seen = shares.values.toSet();
        return seen.length == 1 && seen.first < Frac.one;
      case 'twohalves':
        return shares.values.where((share) => share == _half).length >= 2;
      case 'full':
        return Rules.howMany(mask) == Rules.howManyLanes;
      default:
        return Rules.total(mask) != Frac.of(Rules.greens - 1);
    }
  }

  int? get aimMask => aim == null ? null : Rules.laid(aim!);

  /// The taps the cheapest village takes from the opening.
  int? get fewest =>
      aim == null ? null : Rules.taps(Rules.opening, aimMask!);

  /// The task, told in words.
  String get task => switch (kind) {
        'half' => 'lay lanes so that one of them takes exactly half the '
            'stringings',
        'even' => 'lay lanes so that every lane takes the same share and no '
            'lane takes all of them',
        'twohalves' => 'lay lanes so that two of them take exactly half the '
            'stringings each',
        'full' => 'lay every lane the village can hold',
        _ => 'lay lanes so that the shares add to something other than four',
      };
}
