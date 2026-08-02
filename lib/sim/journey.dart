import 'dart:math';

import 'ground.dart';
import 'library.dart';
import 'runner.dart';

/// A whole go: stretches joined end to end, and the runner on them.
///
/// The world is made ahead of the runner and never behind. Each piece is one
/// the verifier has already got through, and each proof ends with the runner
/// standing on the last tile — so joining them is safe, and the run as a whole
/// is one a player can get through however long it goes on.
///
/// Nothing here is random except which piece comes next, and that comes from a
/// seed. The same seed and the same presses give the same run on any phone,
/// which is what lets a test say a thing about it.
class Journey {
  const Journey._({
    required this.seed,
    required this.run,
    required this.made,
    required this.best,
    required this.laid,
  });

  factory Journey.begin({required int seed}) {
    // A flat run in, so the first thing a player sees is a runner running and
    // not an obstacle.
    var ground = Ground.of('.' * _lead);
    final random = Random(seed);
    final laid = <Laid>[];
    var made = _lead;
    while (made < _keepAhead * 2) {
      final piece = Library.pick(random, jumps: 1);
      laid.add(Laid(at: made, piece: piece));
      ground += piece.ground;
      made += piece.length;
    }

    return Journey._(
      seed: seed,
      run: Run.on(ground),
      made: made,
      best: 0,
      laid: laid,
    );
  }

  /// A journey on ground somebody wrote down.
  ///
  /// Only a test or a screenshot wants this: a run that dies at a chosen place
  /// is not something to wait for. It carries on making world ahead in the
  /// ordinary way once the written ground runs out.
  factory Journey.on(Ground ground, {int seed = 1}) => Journey._(
        seed: seed,
        run: Run.on(ground),
        made: ground.length,
        best: 0,
        laid: const [],
      );

  /// Flat ground at the very start.
  static const _lead = 12;

  /// How much world to keep in front of the runner.
  static const _keepAhead = 60;

  final int seed;
  final Run run;

  /// How many tiles of world have been made.
  final int made;

  /// The furthest the runner has been, in tiles. Only moves forwards.
  final double best;

  /// Every piece put down, and the tile it starts on.
  ///
  /// Kept so the proofs can be found again. Each piece was proved from a
  /// standing start at its own first tile, and the pace is exactly a sixteenth
  /// of a tile a step, so proof step s of a piece laid at tile t is global
  /// step s + 16t — which is what lets a test play a whole run out of nothing
  /// but the stored proofs.
  final List<Laid> laid;

  bool get isOver => run.isOver;

  /// How far the runner has got, which is the score.
  double get distance => run.x;

  int get score => distance.floor();

  /// The journey one step on.
  Journey step({bool holding = false}) {
    if (isOver) return this;

    var journey = this;
    if (made - run.x < _keepAhead) journey = journey._extend();

    final after = journey.run.step(holding: holding);
    return Journey._(
      seed: seed,
      run: after,
      made: journey.made,
      best: after.x > best ? after.x : best,
      laid: journey.laid,
    );
  }

  /// Puts another piece on the end.
  ///
  /// Which piece depends on how far the runner has come, so the run gets
  /// harder the longer it lasts — and on a random drawn from the seed and the
  /// distance, so it is the same run every time and still not the same piece
  /// every time.
  Journey _extend() {
    final random = Random(seed * 104729 + made);
    final piece = Library.pick(random, jumps: Library.reachFor(run.x));
    return Journey._(
      seed: seed,
      run: run.onMore(run.ground + piece.ground),
      made: made + piece.length,
      best: best,
      laid: [...laid, Laid(at: made, piece: piece)],
    );
  }
}

/// A piece, and where it was put down.
class Laid {
  const Laid({required this.at, required this.piece});

  /// The tile its first tile is.
  final int at;

  final Piece piece;

  /// The steps of the whole run on which this piece's proof holds the button.
  ///
  /// The proof was made from a standing start at the piece's own first tile,
  /// and the runner crosses a tile in exactly sixteen steps, so the two line
  /// up by adding.
  Iterable<int> get holdsInRun =>
      piece.holds.map((step) => step + at * Run.stepsPerTile);
}
