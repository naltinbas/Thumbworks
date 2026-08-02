import 'dart:math';

import 'field.dart';
import 'reason.dart';
import 'solve.dart';

/// Lays out boards, and throws away the ones that would need a guess.
///
/// The check is not a heuristic and not a sample. Every board this hands back
/// has been played through from its opening square to its last by [
/// reasonThrough], using only the rules the size allows. A board that stops
/// short is dropped and another is laid out.
class Maker {
  const Maker._();

  /// A board of this shape from this seed, or null if that seed's board is
  /// not the puzzle asked for.
  ///
  /// Dropped for either reason: it would have needed a guess, or it would
  /// have needed less thinking than the size promises.
  ///
  /// Deterministic: the same seed gives the same board on every phone, which
  /// is what lets a test name a board that once went wrong.
  static Field? from({
    required int across,
    required int down,
    required int mines,
    required int seed,
    required Rule needs,
  }) {
    final field = _lay(
      across: across,
      down: down,
      mines: mines,
      seed: seed,
    );
    if (field == null) return null;
    final solved = reasonThrough(field, upTo: needs);
    if (!solved.cleared) return null;
    if (solved.hardest != needs) return null;
    return field;
  }

  /// The first board from [seed] onwards that needs no guessing, and the seed
  /// it came from.
  ///
  /// Takes a while and is meant to: laying out a board that can be finished by
  /// reasoning is a matter of trying until one is, and most are not.
  static ({Field field, int seed, int tried})? find({
    required int across,
    required int down,
    required int mines,
    required int seed,
    required Rule needs,
    int give = 20000,
  }) {
    for (var tried = 0; tried < give; tried++) {
      final field = from(
        across: across,
        down: down,
        mines: mines,
        seed: seed + tried,
        needs: needs,
      );
      if (field != null) {
        return (field: field, seed: seed + tried, tried: tried + 1);
      }
    }
    return null;
  }

  /// Scatters the mines, keeping them off the opening square and everything
  /// touching it — which is what makes the opening blank, and so what makes
  /// it open a region rather than one square.
  static Field? _lay({
    required int across,
    required int down,
    required int mines,
    required int seed,
  }) {
    final cells = across * down;
    final dice = Random(seed);
    final opening = dice.nextInt(cells);

    final blank = Field(
      across: across,
      down: down,
      mines: const {},
      opening: opening,
    );
    final barred = {opening, ...blank.around(opening)};
    final room = [
      for (var at = 0; at < cells; at++)
        if (!barred.contains(at)) at,
    ];
    if (room.length < mines) return null;

    // Fisher-Yates as far as it needs to go, rather than shuffling the whole
    // board to take a tenth of it.
    for (var i = 0; i < mines; i++) {
      final j = i + dice.nextInt(room.length - i);
      final held = room[i];
      room[i] = room[j];
      room[j] = held;
    }

    return Field(
      across: across,
      down: down,
      mines: room.take(mines).toSet(),
      opening: opening,
    );
  }
}
