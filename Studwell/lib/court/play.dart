import 'court.dart';
import 'rules.dart';

/// A court being paved. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.court, this.rules, this.laid, this.pending, this.moves,
      this.before);

  factory Play.of(Court court) => Play._(
      court, Rules(court.side, court.well), const [], const [], 0, null);

  /// A play stood at a paving, for the mark and the tests.
  factory Play.standing(Court court, List<List<int>> paving) => Play._(
      court,
      Rules(court.side, court.well),
      [for (final elbow in paving) List.of(elbow)..sort()],
      const [],
      paving.length,
      null);

  final Court court;
  final Rules rules;

  /// The elbows on the court, each three sorted cells.
  final List<List<int>> laid;

  /// The flags tapped toward the next elbow, at most two.
  final List<int> pending;

  /// Layings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless court admits it.
  static const gaveUpAt = 13;

  bool get isDone => rules.lands(laid);

  bool get gaveUp => !court.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The elbow over a cell, or null for a bare flag.
  List<int>? elbowAt(int cell) {
    for (final elbow in laid) {
      if (elbow.contains(cell)) return elbow;
    }
    return null;
  }

  /// The bare flags, the well not among them.
  List<int> get bare => [
        for (var cell = 0; cell < rules.cells; cell++)
          if (cell != court.well && elbowAt(cell) == null) cell,
      ];

  /// The studs still showing: bare, and not the well.
  List<int> get bareStuds =>
      [for (final cell in bare) if (rules.isStud(cell)) cell];

  bool touches(int cell) =>
      !isOver && cell >= 0 && cell < rules.cells && cell != court.well;

  /// Taps a flag: lifts the elbow over it, or unpicks it, or
  /// picks it toward an elbow, laying the elbow on the third
  /// pick when the three make one and starting over on the new
  /// flag when they do not.
  Play tap(int cell) {
    if (!touches(cell)) return this;
    final over = elbowAt(cell);
    if (over != null) {
      final left = [
        for (final elbow in laid)
          if (elbow != over) elbow,
      ];
      return Play._(court, rules, left, const [], moves + 1, this);
    }
    if (pending.contains(cell)) {
      return Play._(court, rules, laid,
          [for (final held in pending) if (held != cell) held], moves,
          before);
    }
    final picked = [...pending, cell];
    if (picked.length < 3) {
      return Play._(court, rules, laid, picked, moves, before);
    }
    if (!rules.isElbow(picked)) {
      return Play._(court, rules, laid, [cell], moves, before);
    }
    return Play._(court, rules, [...laid, picked..sort()], const [],
        moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', elbow) for an elbow
  /// laid off the aim, or ('lay', elbow) for the next elbow of
  /// the aim; null when nothing lands.
  (String, List<int>)? get next {
    if (isOver || !court.winnable) return null;
    final aim = rules.quartering() ?? rules.landing();
    if (aim == null) return null;
    final aimed = {for (final elbow in aim) elbow.join(',')};
    for (final elbow in laid) {
      if (!aimed.contains(elbow.join(','))) return ('lift', elbow);
    }
    final have = {for (final elbow in laid) elbow.join(',')};
    for (final elbow in aim) {
      if (!have.contains(elbow.join(','))) return ('lay', elbow);
    }
    return null;
  }
}
