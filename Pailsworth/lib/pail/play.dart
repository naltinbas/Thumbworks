import 'errand.dart';
import 'rules.dart';

/// An errand being run. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.errand, this.rules, this.held, this.pours, this.before);

  Play.of(Errand errand)
      : this._(errand, _rulesFor(errand),
            List<int>.filled(errand.caps.length, 0), 0, null);

  final Errand errand;
  final Rules rules;

  /// What each pail holds.
  final List<int> held;

  /// Pours made so far.
  final int pours;

  final Play? before;

  static final _kept = <String, Rules>{};

  static Rules _rulesFor(Errand errand) =>
      _kept[errand.caps.join(',')] ??= Rules(errand.caps);

  /// The spring and the drain, as the pour ends name them.
  static const spring = -1;
  static const drain = -2;

  bool get isDone => held.contains(errand.ask);

  /// Whether a pour may be made from one end to the other.
  bool mayPour(int from, int to) {
    if (from == spring) {
      return to >= 0 &&
          to < rules.pails &&
          held[to] < errand.caps[to];
    }
    if (to == drain) {
      return from >= 0 && from < rules.pails && held[from] > 0;
    }
    return from >= 0 &&
        to >= 0 &&
        from != to &&
        from < rules.pails &&
        to < rules.pails &&
        held[from] > 0 &&
        held[to] < errand.caps[to];
  }

  /// One pour. The errand comes back unchanged if it may not be made.
  Play pour(int from, int to) {
    if (isDone || !mayPour(from, to)) return this;
    return Play._(errand, rules, rules.poured(held, from, to),
        pours + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest pours from here to the errand, or null.
  int? get fewestFromHere => rules.fewestFrom(held, errand.ask);

  /// A pour that steps one nearer, or null.
  (int, int)? get next => rules.next(held, errand.ask);
}
