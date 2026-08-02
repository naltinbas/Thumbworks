import 'dart:typed_data';

import 'rules.dart';

/// How often each move wins, from a position, played perfectly ever after.
class Chance {
  const Chance({required this.bank, required this.one, required this.two});

  /// The chance of winning the game after banking, after one die, and after
  /// two.
  final double bank;
  final double one;
  final double two;

  double of(Move move) => switch (move) {
        Move.bank => bank,
        Move.one => one,
        Move.two => two,
      };

  /// The best of them.
  Move get best {
    var pick = Move.bank;
    var most = bank;
    if (one > most) {
      pick = Move.one;
      most = one;
    }
    if (two > most) {
      pick = Move.two;
      most = two;
    }
    return pick;
  }

  double get bestChance => of(best);

  /// What the second best move costs, as a share of the game.
  double get gap {
    final others = [bank, one, two]..sort();
    return others[2] - others[1];
  }
}

/// The exact chance of winning from every position there is.
///
/// Worked out, not guessed at. The value of a position depends on the value of
/// positions that depend back on it — you bank, they play, they hand back —
/// so there is no order to fill a table in. What there is instead is a
/// starting guess and a rule that improves it, applied until it stops
/// changing, which is what [Odds.reckon] does.
class Odds {
  Odds._(this._win, this.sweeps, this.drift);

  /// The chance the player to move wins, indexed by score, their score and
  /// what this turn is worth.
  final Float64List _win;

  /// How many times the whole table was gone over before it settled.
  final int sweeps;

  /// How much the last sweep moved anything. What "settled" means.
  final double drift;

  /// The table and the two numbers describing how it was found, in a shape
  /// that can be handed from one isolate to another.
  ///
  /// The table takes a second to work out and the phone should not be holding
  /// still while it happens, so it is worked out somewhere else and sent over
  /// as this.
  ({Float64List table, int sweeps, double drift}) get parts =>
      (table: _win, sweeps: sweeps, drift: drift);

  factory Odds.fromParts(
    ({Float64List table, int sweeps, double drift}) parts,
  ) =>
      Odds._(parts.table, parts.sweeps, parts.drift);

  static const _target = Rules.target;

  /// How much room each pair of scores gets for turn totals.
  ///
  /// Twenty four more than there are, and every one of those is filled with a
  /// one and never written to. A turn total past the winning post means the
  /// game is already won, and padding the table with that answer is what lets
  /// the solver's inner loop read the table twenty times without asking once
  /// whether it has gone off the end.
  static const _stride = _target + 24;

  static int _at(int mine, int theirs, int turn) =>
      (mine * _target + theirs) * _stride + turn;

  /// The chance the player to move wins from here.
  ///
  /// [mine] and [theirs] are banked scores, [turn] is what this turn has made
  /// and has not banked yet.
  double winning(int mine, int theirs, int turn) {
    if (mine + turn >= _target) return 1;
    if (theirs >= _target) return 0;
    return _win[_at(mine, theirs, turn)];
  }

  /// What each move is worth from here.
  Chance chanceAt(int mine, int theirs, int turn) => Chance(
        bank: _afterBank(mine, theirs, turn),
        one: _afterOne(mine, theirs, turn),
        two: _afterTwo(mine, theirs, turn),
      );

  /// The move that wins most often. There is always exactly one answer, and
  /// it is not a matter of opinion.
  Move bestAt(int mine, int theirs, int turn) =>
      chanceAt(mine, theirs, turn).best;

  double _afterBank(int mine, int theirs, int turn) {
    final banked = mine + turn;
    if (banked >= _target) return 1;
    // They are to move now, so their chance of winning is theirs to take and
    // whatever is left over is ours.
    return 1 - winning(theirs, banked, 0);
  }

  double _afterOne(int mine, int theirs, int turn) {
    // A one loses the turn and hands over.
    var total = 1 - winning(theirs, mine, 0);
    for (var face = 2; face <= Rules.faces; face++) {
      total += winning(mine, theirs, turn + face);
    }
    return total / Rules.faces;
  }

  double _afterTwo(int mine, int theirs, int turn) {
    var total = 0.0;
    for (var first = 1; first <= Rules.faces; first++) {
      for (var second = 1; second <= Rules.faces; second++) {
        if (first == 1 && second == 1) {
          // Both ones: the turn goes, and so does everything banked.
          total += 1 - winning(theirs, 0, 0);
        } else if (first == 1 || second == 1) {
          total += 1 - winning(theirs, mine, 0);
        } else {
          total += winning(mine, theirs, turn + Rules.paidFor(first, second));
        }
      }
    }
    return total / (Rules.faces * Rules.faces);
  }

  /// Works the whole table out.
  ///
  /// Sweeps the table over and over, each time replacing every position with
  /// the best its three moves are worth given what the table says now. Every
  /// sweep moves every number closer to the truth and none of them ever moves
  /// further from it, so this stops when a whole sweep has moved nothing by
  /// more than [settled].
  ///
  /// The sweep goes downwards through all three — the score, their score and
  /// the turn — because every move leads either to a bigger turn or to a
  /// bigger banked score. So the positions a move leads to have already been
  /// improved this time round rather than last, and the whole thing settles in
  /// a couple of dozen sweeps instead of a couple of hundred.
  static Odds reckon({double settled = 1e-11, int mostSweeps = 300}) {
    final win = Float64List(_target * _target * _stride);
    // A first guess of an even game everywhere, and a one in every place a
    // turn total has already won the game.
    for (var mine = 0; mine < _target; mine++) {
      final over = _target - mine;
      for (var theirs = 0; theirs < _target; theirs++) {
        final row = (mine * _target + theirs) * _stride;
        for (var turn = 0; turn < over; turn++) {
          win[row + turn] = 0.5;
        }
        for (var turn = over; turn < _stride; turn++) {
          win[row + turn] = 1;
        }
      }
    }

    // Reading straight out of the table rather than through [winning]. A
    // sweep asks this ten million times, so the index arithmetic in the inner
    // loop below is written out rather than called.
    double at(int mine, int theirs, int turn) {
      if (mine + turn >= _target) return 1;
      return win[(mine * _target + theirs) * _stride + turn];
    }

    var sweeps = 0;
    var drift = 1.0;
    while (drift > settled && sweeps < mostSweeps) {
      drift = 0;
      for (var mine = _target - 1; mine >= 0; mine--) {
        for (var theirs = _target - 1; theirs >= 0; theirs--) {
          // None of these change while the turn total does, so they are read
          // once for the whole run of turns rather than once a turn.
          final lostTurn = 1 - at(theirs, mine, 0);
          final lostAll = 1 - at(theirs, 0, 0);
          final row = (mine * _target + theirs) * _stride;
          final over = _target - mine;
          // Banking always lands on a score of less than the target here,
          // because a turn worth more than that has already won.
          final theirRow = theirs * _target * _stride + mine * _stride;

          for (var turn = over - 1; turn >= 0; turn--) {
            var most = 1 - win[theirRow + turn * _stride];

            var one = lostTurn +
                win[row + turn + 2] +
                win[row + turn + 3] +
                win[row + turn + 4] +
                win[row + turn + 5] +
                win[row + turn + 6];
            one /= Rules.faces;
            if (one > most) most = one;

            // What two dice with no one on them can pay, and how often —
            // written out, because a loop over a list here allocates nothing
            // but costs a bounds check a payout and this runs fifty million
            // times a sweep. Rules.boldPays says the same thing in one place,
            // and a test holds the two against each other.
            var two = lostTurn * 10 +
                lostAll +
                win[row + turn + 5] * 2 +
                win[row + turn + 6] * 2 +
                win[row + turn + 7] * 4 +
                win[row + turn + 8] * 5 +
                win[row + turn + 9] * 4 +
                win[row + turn + 10] * 2 +
                win[row + turn + 11] * 2 +
                win[row + turn + 12] +
                win[row + turn + 16] +
                win[row + turn + 20] +
                win[row + turn + 24];
            two /= Rules.faces * Rules.faces;
            if (two > most) most = two;

            final moved = (most - win[row + turn]).abs();
            if (moved > drift) drift = moved;
            win[row + turn] = most;
          }
        }
      }
      sweeps++;
    }

    return Odds._(win, sweeps, drift);
  }
}

/// Works out the whole table, for handing back from another isolate.
///
/// A top level function, because that is what can be started on an isolate of
/// its own.
({Float64List table, int sweeps, double drift}) reckonParts([void _]) =>
    Odds.reckon().parts;
