import 'rules.dart';

/// One ask: how many of the eight hattings the agreement is to win, and
/// whether anybody is to hold their tongue throughout.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.hattings,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'loud': so many hattings won with everybody speaking on something;
  /// 'quiet': so many with one villager silent throughout; 'plain': so
  /// many, however they are won; 'past': more than any agreement can
  /// win.
  final String kind;

  /// How many of the eight hattings the ask wants won.
  final int hattings;

  /// How many agreements land it, from the sweep.
  final int ways;

  /// The cheapest agreement that lands it, from the sweep; empty when
  /// none does.
  final List<List<int>> aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether [agreement] lands the ask.
  bool meets(List<List<int>> agreement) {
    if (!Rules.valid(agreement)) return false;
    final wins = Rules.wins(agreement);
    switch (kind) {
      case 'loud':
        return wins == hattings && !Rules.hasQuiet(agreement);
      case 'quiet':
        return wins == hattings && Rules.hasQuiet(agreement);
      case 'past':
        return wins >= hattings;
      default:
        return wins == hattings;
    }
  }

  /// The taps the cheapest agreement takes from silence.
  int? get fewest => winnable ? Rules.taps(aim) : null;

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'loud':
        return 'agree a rule that wins $hattings of the eight hattings with '
            'nobody silent throughout';
      case 'quiet':
        return 'agree a rule that wins $hattings of the eight hattings with '
            'one villager silent throughout';
      case 'past':
        return 'agree a rule that wins $hattings of the eight hattings or '
            'more';
      default:
        return 'agree a rule that wins $hattings of the eight hattings';
    }
  }
}
