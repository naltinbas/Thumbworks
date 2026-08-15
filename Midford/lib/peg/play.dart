import 'cording.dart';
import 'rules.dart';

/// A cording being pegged. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.cording, this.rules, this.pegs, this.moves, this.before);

  factory Play.of(Cording cording) => Play._(cording, Rules(), List.of(cording.given), 0, null);

  /// A play stood at four pegs, for the mark and the tests.
  factory Play.standing(Cording cording, List<Peg> pegs) =>
      Play._(cording, Rules(), List.of(pegs), pegs.length, null);

  final Cording cording;
  final Rules rules;

  /// The pegs set, in order.
  final List<Peg> pegs;

  /// Pegs set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless cording admits it.
  static const gaveUpAt = 12;

  bool get full => pegs.length == 4;

  bool get isDone => full && cording.meets(pegs);

  bool get gaveUp => !cording.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool isGiven(Peg peg) => cording.given.contains(peg);

  /// Taps a peg place: lifts the last peg when it is there, or sets
  /// the next peg.
  Play tap(Peg peg) {
    if (isOver || peg.$1 < 0 || peg.$1 >= rules.side || peg.$2 < 0 || peg.$2 >= rules.side) return this;
    if (pegs.contains(peg)) {
      if (isGiven(peg) || pegs.last != peg) return this;
      return Play._(cording, rules, pegs.sublist(0, pegs.length - 1), moves + 1, this);
    }
    if (full) return this;
    return Play._(cording, rules, [...pegs, peg], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the sham says the figure is, as it stands.
  String get figure {
    if (!full) return 'unfinished';
    if (!Rules.hasRoom(pegs)) return 'flat';
    if (Rules.squareByDiagonals(pegs)) return 'a square';
    if (Rules.rectangleByDiagonals(pegs)) return 'a rectangle';
    if (Rules.rhombusByDiagonals(pegs)) return 'a rhombus';
    return 'a parallelogram';
  }

  /// What the show-me points at: ('lift', peg) for a set peg off the
  /// aim, or ('set', peg) for the next peg of the aim; null when
  /// nothing lands.
  (String, Peg)? get next {
    if (isOver || !cording.winnable) return null;
    final aim = aimFor(cording);
    if (aim == null) return null;
    for (var i = 0; i < pegs.length; i++) {
      if (pegs[i] != aim[i]) return ('lift', pegs.last);
    }
    return pegs.length < 4 ? ('set', aim[pegs.length]) : null;
  }

  /// The sweep's first landing four, kept once found.
  static List<Peg>? aimFor(Cording cording) {
    final key = cording.name;
    if (!_aims.containsKey(key)) {
      List<Peg>? found;
      Rules().fours((four) {
        if (found != null) return;
        for (var i = 0; i < cording.given.length; i++) {
          if (four[i] != cording.given[i]) return;
        }
        if (cording.meets(four)) found = List.of(four);
      });
      _aims[key] = found;
    }
    return _aims[key];
  }

  static final _aims = <String, List<Peg>?>{};
}
