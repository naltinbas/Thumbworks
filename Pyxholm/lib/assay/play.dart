import 'fewest.dart';
import 'pyx.dart';

/// One weighing that has been made, and how the beam went.
class Told {
  const Told(this.weighing, this.tip);

  final Weighing weighing;
  final Tip tip;
}

/// A box part way through.
class Play {
  Play._(this.pyx, this.assay, this.standing, this.told, this.onLeft,
      this.onRight);

  factory Play.of(Pyx pyx, Assay assay) =>
      Play._(pyx, assay, pyx.everything, const [], const {}, const {});

  final Pyx pyx;

  /// The searching. One per box, so what it works out is kept.
  final Assay assay;

  /// Everything that could still be true.
  final List<Verdict> standing;

  /// The weighings made so far, and what they said.
  final List<Told> told;

  /// The coins sitting on each pan, waiting to be weighed.
  final Set<int> onLeft;
  final Set<int> onRight;

  int get weighings => told.length;

  bool get isDone => standing.length == 1;

  Verdict? get answer => isDone ? standing.first : null;

  bool get isFewest => isDone && weighings <= pyx.fewest;

  /// Whether the pans are ready to go on the beam.
  bool get canWeigh =>
      !isDone && onLeft.length == onRight.length && onLeft.isNotEmpty;

  /// Where a coin is: -1 aside, 0 on the left pan, 1 on the right.
  int placeOf(int coin) =>
      onLeft.contains(coin) ? 0 : (onRight.contains(coin) ? 1 : -1);

  /// Whether a coin could still be the heavy one, the light one, both, or
  /// neither.
  bool couldBeHeavy(int coin) =>
      standing.any((verdict) => verdict.coin == coin && verdict.heavy);

  bool couldBeLight(int coin) =>
      standing.any((verdict) => verdict.coin == coin && !verdict.heavy);

  bool isCleared(int coin) => !couldBeHeavy(coin) && !couldBeLight(coin);

  /// Moves a coin on: aside, then the left pan, then the right, then aside.
  Play move(int coin) {
    if (isDone || coin < 0 || coin >= pyx.coins) return this;
    final left = Set.of(onLeft);
    final right = Set.of(onRight);
    if (left.remove(coin)) {
      right.add(coin);
    } else if (!right.remove(coin)) {
      left.add(coin);
    }
    return Play._(pyx, assay, standing, told, left, right);
  }

  Play get clearPans =>
      Play._(pyx, assay, standing, told, const {}, const {});

  /// Puts the pans on the beam. The answer that comes back is the one that
  /// leaves the most still to do, so nothing is ever settled by luck.
  Play weigh() {
    if (!canWeigh) return this;
    final weighing = Weighing(onLeft.toList(), onRight.toList());
    final tip = assay.answerFor(weighing, standing);
    return Play._(
      pyx,
      assay,
      weighing.after(standing, tip),
      [...told, Told(weighing, tip)],
      const {},
      const {},
    );
  }

  Play get back {
    if (told.isEmpty) return this;
    var standing = pyx.everything;
    for (final was in told.sublist(0, told.length - 1)) {
      standing = was.weighing.after(standing, was.tip);
    }
    return Play._(
      pyx,
      assay,
      standing,
      told.sublist(0, told.length - 1),
      const {},
      const {},
    );
  }

  Play get again => Play.of(pyx, assay);

  /// The fewest weighings still needed, whatever the beam says.
  ///
  /// The number for an untouched box is written down rather than worked out,
  /// because on twelve coins it takes a few seconds and it is the same every
  /// time. Everything after the first weighing is a handful of verdicts and
  /// settles at once.
  int get restNeeded => told.isEmpty
      ? pyx.fewest
      : (assay.fewestFor(standing) ?? pyx.fewest);

  /// The best this box can now be settled in, counting the weighings made.
  int get couldFinishIn => weighings + restNeeded;

  /// Asked. A weighing to make next that still settles the box in as few more
  /// as it can now be settled in.
  Weighing? get next => isDone ? null : assay.nextFor(standing);
}
