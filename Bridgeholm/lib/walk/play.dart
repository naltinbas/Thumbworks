import 'rules.dart';
import 'town.dart';

/// A walk being walked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.town, this.rules, this.standing, this.walked, this.order,
      this.before);

  Play.of(Town town) : this._(town, Rules(town), null, 0, const [], null);

  final Town town;
  final Rules rules;

  /// The ground stood on, or null before the walk starts.
  final int? standing;

  /// The walked bridges, as bits.
  final int walked;

  /// The bridges in the order they were walked.
  final List<int> order;

  final Play? before;

  bool get started => standing != null;

  int get crossed => order.length;

  bool get isDone => walked == (1 << rules.bridgeCount) - 1;

  bool bridgeWalked(int bridge) => walked & (1 << bridge) != 0;

  /// Stands the walk on a ground to start. Only before the first
  /// crossing.
  Play stand(int ground) {
    if (started || ground < 0 || ground >= town.grounds.length) {
      return this;
    }
    return Play._(town, rules, ground, walked, order, this);
  }

  /// Whether the bridge can be crossed from where the walk stands.
  bool mayCross(int bridge) =>
      started &&
      !isDone &&
      bridge >= 0 &&
      bridge < rules.bridgeCount &&
      !bridgeWalked(bridge) &&
      rules.across(bridge, standing!) != null;

  /// Crosses a bridge. The walk comes back unchanged if it may not.
  Play cross(int bridge) {
    if (!mayCross(bridge)) return this;
    return Play._(
      town,
      rules,
      rules.across(bridge, standing!),
      walked | (1 << bridge),
      [...order, bridge],
      this,
    );
  }

  Play get back => before ?? this;

  /// Whether the walk can still finish from where it stands.
  bool get canStill =>
      !started ? rules.walkable : rules.canStillWalk(standing!, walked);

  /// Whether the walk stands somewhere with no unwalked bridge out.
  bool get stuck {
    if (!started || isDone) return false;
    for (var bridge = 0; bridge < rules.bridgeCount; bridge++) {
      if (mayCross(bridge)) return false;
    }
    return true;
  }

  /// The bridge a finishing walk crosses next, or the ground to stand
  /// on, spoken as a record. Null when nothing finishes.
  int? get nextBridge =>
      !started || isDone ? null : rules.next(standing!, walked);

  int? get nextStart => started ? null : rules.goodStart();
}
