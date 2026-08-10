import 'chase.dart';
import 'chases.dart';
import 'fewest.dart';
import 'parity.dart';

/// A forme part slid.
class Play {
  Play._(this.forme, this.slides, this.stands, this.made, this.mended);

  factory Play.of(Forme forme, Slides slides) =>
      Play._(forme, slides, List.of(forme.start), 0, false);

  final Forme forme;

  /// The table of distances, kept for as long as the forme is open.
  final Slides slides;

  /// Which letter stands in each cell, or -1 for the empty one.
  final List<int> stands;

  /// How many slides have been made.
  final int made;

  /// Whether the dropped pair has been swapped back.
  final bool mended;

  Chase get chase => forme.chase;

  int get empty => stands.indexOf(-1);

  int sortIn(int cell) => stands[cell];

  /// The cells whose letter could be slid into the empty one.
  List<int> get canSlide => chase.beside(empty);

  bool get isLocked => chase.isLocked(stands);

  bool get isFewest => isLocked && made <= forme.fewest;

  /// Whether this arrangement can ever be made to read right.
  bool get canBeLocked => slides.canBeLocked(stands);

  /// What the frame reads as it stands.
  String get reads => chase.reads(stands);

  /// Slides the letter in a cell into the empty one, when they are beside
  /// each other.
  Play slide(int cell) {
    if (isLocked || cell < 0 || cell >= chase.cells) return this;
    if (!canSlide.contains(cell)) return this;
    return Play._(forme, slides, Slides.slide(stands, cell), made + 1, mended);
  }

  /// Swaps the dropped pair back. Only the dropped forme ever needs it, and
  /// only before it has been done.
  Play mend() {
    final pair = Parity.swapThatWouldDoIt(chase, stands);
    if (pair == null) return this;
    final next = [
      for (final sort in stands)
        sort == pair.$1 ? pair.$2 : (sort == pair.$2 ? pair.$1 : sort),
    ];
    return Play._(forme, slides, next, made, true);
  }

  Play get again => Play.of(forme, slides);

  /// The fewest slides still to come from where the type stands, or null on a
  /// forme that cannot be locked.
  int? get left => slides.from(stands);

  /// The best this forme can now be finished in, counting the slides made.
  int? get couldFinishIn {
    final rest = left;
    return rest == null ? null : made + rest;
  }

  /// Asked. The cell whose letter should be slid next, on a shortest way to
  /// reading right. Read off the table from where the type actually stands,
  /// so it is still right after a wrong slide.
  int? get next => slides.nextFrom(stands);

  /// The pairs of letters out of order, for the game to count out loud.
  int get outOfOrder => Parity.outOfOrder(stands).length;
}
