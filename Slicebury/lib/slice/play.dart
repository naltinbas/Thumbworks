import 'cake.dart';
import 'rules.dart';

/// A cake being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.cake, this.picked, this.moves, this.before);

  factory Play.of(Cake cake) => Play._(cake, const [], 0, null);

  /// A play stood at a pick, for the mark and the tests.
  factory Play.standing(Cake cake, List<int> picked) =>
      Play._(cake, List.of(picked)..sort(), picked.length, null);

  final Cake cake;

  /// The spots holding candles, sorted.
  final List<int> picked;

  /// Settings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless cake admits it.
  static const gaveUpAt = 16;

  int get slices => Rules.slicesByEuler(picked);
  int get slicesByCuts => Rules.slicesByCuts(picked);

  bool get isDone =>
      picked.length == cake.candles && slices == cake.slices;

  bool get gaveUp => !cake.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets or lifts the candle at a spot; a seventh candle is
  /// refused.
  Play tapAt(int spot) {
    if (isOver || spot < 0 || spot >= Rules.spots.length) {
      return this;
    }
    if (picked.contains(spot)) {
      return Play._(
          cake,
          [for (final at in picked) if (at != spot) at],
          moves + 1,
          this);
    }
    if (picked.length == cake.candles) return this;
    return Play._(
        cake, [...picked, spot]..sort(), moves + 1, this);
  }

  Play get back => before ?? this;

  /// The spot the show-me points at: a stray candle to lift or
  /// a missing spot of the nearest landing pick; null when none
  /// lands.
  int? get next {
    if (isOver || !cake.winnable) return null;
    List<int>? bestAim;
    var nearest = 1 << 30;
    Rules.picks(cake.candles, (aim) {
      if (Rules.slicesByEuler(aim) != cake.slices) return;
      final apart = <int>{...picked, ...aim}.length * 2 -
          picked.length -
          aim.length;
      if (apart < nearest) {
        nearest = apart;
        bestAim = List.of(aim);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (final spot in picked) {
      if (!aim.contains(spot)) return spot;
    }
    for (final spot in aim) {
      if (!picked.contains(spot)) return spot;
    }
    return null;
  }
}
