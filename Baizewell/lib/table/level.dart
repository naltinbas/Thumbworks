import 'rules.dart';

/// One ask: a table to set, sides along and up, for where the ball goes.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.count = 0,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'far', 'right', 'top', 'home': the pocket the ball must find;
  /// 'bounces': exactly [count] bounces; 'most': the most bounces there
  /// are on the sham.
  final String kind;
  final int count;

  /// How many of the sham's tables land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  /// The tables there are: sides two to twelve, along and up.
  int get settings => Rules.sweep((p, q) => true).$2;

  bool get winnable => ways > 0;

  /// Whether the p by q table lands the ask.
  bool meets(int p, int q) {
    final pocket = Rules.pocketByParity(p, q);
    switch (kind) {
      case 'far':
        return pocket == (p, q);
      case 'right':
        return pocket == (p, 0);
      case 'top':
        return pocket == (0, q);
      case 'home':
        return pocket == (0, 0);
      case 'bounces':
        return Rules.bouncesByFormula(p, q) == count;
      default:
        final mine = Rules.bouncesByFormula(p, q);
        var most = true;
        Rules.sweep((a, b) {
          if (Rules.bouncesByFormula(a, b) > mine) most = false;
          return false;
        });
        return most;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'far':
        return 'set the table so the ball drops in the far pocket';
      case 'right':
        return 'set the table so the ball drops in the right-hand pocket';
      case 'top':
        return 'set the table so the ball drops in the top pocket';
      case 'home':
        return 'set the table so the ball comes back to the pocket it left';
      case 'bounces':
        return 'set the table so the ball bounces ${count == 1 ? 'once' : '$count times'} on the way';
      default:
        return 'set the table where the ball bounces the most it does on the sham';
    }
  }
}
