import 'rules.dart';

/// One ask: a stall to set, doors and doors opened and stay or switch.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.num = 0,
    this.den = 1,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'exact': the policy wins num/den exactly; 'over': the policy wins
  /// more than num/den; 'least': the setting where switching wins the
  /// least it ever does on the sham; 'stay': staying beats switching.
  final String kind;
  final int num;
  final int den;

  /// How many of the sham's settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  /// The settings there are: doors three to ten, opened one to n - 2,
  /// stay or switch.
  int get settings => Rules.sweep((n, k, sw) => true).$2;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int doors, int opened, bool switching) {
    final chance = Rules.byFormula(doors, opened, switching);
    switch (kind) {
      case 'exact':
        return chance == (num, den);
      case 'over':
        return Rules.compare(chance, (num, den)) > 0;
      case 'least':
        if (!switching) return false;
        var least = true;
        Rules.sweep((n, k, sw) {
          if (sw && Rules.compare(Rules.byFormula(n, k, true), chance) < 0) least = false;
          return false;
        });
        return least;
      default:
        return !switching && Rules.compare(chance, Rules.byFormula(doors, opened, true)) > 0;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'exact':
        return 'set the stall so the policy wins ${_told(num)} in ${_told(den)} exactly';
      case 'over':
        return 'set the stall so the policy wins more than ${num == 1 && den == 2 ? 'half' : '${_told(num)} in ${_told(den)}'} the games';
      case 'least':
        return 'set the stall where switching wins the least it ever does on the sham';
      default:
        return 'set the stall so that staying wins more games than switching';
    }
  }

  static String _told(int n) => switch (n) {
        2 => 'two',
        3 => 'three',
        4 => 'four',
        9 => 'nine',
        10 => 'ten',
        _ => '$n',
      };
}
