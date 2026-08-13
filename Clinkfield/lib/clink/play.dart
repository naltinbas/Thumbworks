import 'feast.dart';
import 'rules.dart';

/// A feast being raised. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.feast, this.rules, this.clinked, this.moves, this.before);

  factory Play.of(Feast feast) => Play._(
      feast,
      Rules(feast.guests),
      List.filled(Rules(feast.guests).pairs.length, false),
      0,
      null);

  /// A play stood at a feast, for the mark and the tests.
  factory Play.standing(Feast feast, List<bool> clinked) =>
      Play._(feast, Rules(feast.guests), List.of(clinked),
          clinked.where((held) => held).length, null);

  final Feast feast;
  final Rules rules;

  /// One bool per pair: whether they clinked.
  final List<bool> clinked;

  /// Clinks and takings-back, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless feast admits it.
  static const gaveUpAt = 14;

  List<int> get counts => rules.counts(clinked);

  int get distinct => rules.distinct(clinked);

  /// How many clinks stand.
  int get raised => clinked.where((held) => held).length;

  /// Landed only with a clink standing: the bare table already
  /// levels at one count, and a feast must be feasted.
  bool get isDone => raised > 0 && distinct == feast.asked;

  bool get gaveUp => !feast.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Clinks or takes back one pair.
  Play flipAt(int pair) {
    if (isOver || pair < 0 || pair >= rules.pairs.length) {
      return this;
    }
    final turned = List.of(clinked);
    turned[pair] = !turned[pair];
    return Play._(feast, rules, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pair the show-me points at: toward a nearest landing
  /// feast; null when none lands.
  int? get next {
    if (isOver || !feast.winnable) return null;
    List<bool>? bestAim;
    var nearest = 1 << 30;
    rules.feasts((aim) {
      if (rules.distinct(aim) != feast.asked) return;
      // The silent feast cannot be landed: a feast must be
      // feasted, so the pointer never aims at bare.
      if (!aim.contains(true)) return;
      var apart = 0;
      for (var at = 0; at < clinked.length; at++) {
        if (clinked[at] != aim[at]) apart++;
      }
      if (apart < nearest) {
        nearest = apart;
        bestAim = List.of(aim);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (var at = 0; at < clinked.length; at++) {
      if (clinked[at] != aim[at]) return at;
    }
    return null;
  }
}
