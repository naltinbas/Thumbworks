import 'cheapest.dart';
import 'parish.dart';

/// A parish part joined up.
class Play {
  Play._(this.parish, this.answer, this.cut);

  factory Play.of(Parish parish, Network answer) =>
      Play._(parish, answer, const {});

  final Parish parish;

  /// The cheapest network there is, worked out when the parish opens.
  final Network answer;

  /// The paths cut so far.
  final Set<int> cut;

  bool has(int trod) => cut.contains(trod);

  int get yards => parish.yardsOf(cut);

  bool get isDone => parish.joinsItAll(cut);

  bool get isCheapest => isDone && yards == answer.yards;

  /// Whether cutting a path now would close a loop.
  bool wouldLoop(int trod) => !has(trod) && parish.wouldLoop(cut, trod);

  /// Which piece of the parish each hamlet is in.
  List<int> get sides => parish.sidesWith(cut);

  /// How many pieces the parish is still in.
  int get pieces => sides.toSet().length;

  Play touch(int trod) {
    if (trod < 0 || trod >= parish.many) return this;
    if (has(trod)) return Play._(parish, answer, {...cut}..remove(trod));
    if (parish.wouldLoop(cut, trod)) return this;
    return Play._(parish, answer, {...cut, trod});
  }

  Play get again => Play.of(parish, answer);

  /// The least the whole parish can still be joined for, counting what is cut.
  ///
  /// The same method, cheapest first over the paths that are left, started
  /// from what has been cut rather than from nothing. A different question
  /// from the one answered when the parish opened, and no dearer.
  int get couldStillCost => Cheapests.from(parish, cut).yards;

  /// Asked. The path to cut next that still leaves the whole thing joinable
  /// for as little as it can now be. Worked out from what is cut rather than
  /// read off the answer the parish opened with, so it is still right after a
  /// bad path.
  int? get next {
    final rest = Cheapests.from(parish, cut).cut;
    for (final trod in rest) {
      if (!cut.contains(trod)) return trod;
    }
    return null;
  }

  /// Why a path has to be in every cheapest network: the line it crosses.
  MustBeIn whyIn(int trod) => Cheapests.whyIn(parish, answer.cut, trod);

  /// Why a path is in no cheapest network: the loop it is the dearest on.
  NeverIn? whyNot(int trod) => Cheapests.whyNot(parish, answer.cut, trod);
}
