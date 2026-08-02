import 'ground.dart';
import 'runner.dart';

/// What a search of a stretch came to.
class Passable {
  const Passable({
    required this.through,
    required this.holds,
    required this.looked,
    required this.gaveUp,
  });

  /// Whether there is a way to the end at all.
  final bool through;

  /// The steps on which the button was held, in order. A proof: play these
  /// and the stretch comes out.
  final List<int> holds;

  /// How many states were looked at.
  final int looked;

  /// Whether it ran out of patience rather than out of states.
  final bool gaveUp;

  /// Whether the stretch needs the button at all. A flat run of ground is
  /// passable and is not a stretch worth having.
  bool get needsJumping => holds.isNotEmpty;
}

/// Works out whether a stretch can be got through, by playing it.
///
/// This is the whole of what makes the game fair. A generated stretch is a
/// pile of numbers and there is no looking at it and knowing: the only honest
/// question is whether a player pressing that one button at the right moments
/// gets to the end, and the only honest answer is to try.
///
/// So this presses the button. At every step it takes both branches — held and
/// not — and remembers where it has been, which is what turns two to the power
/// of four hundred into a few thousand states. What comes back is either the
/// steps to hold on, which is a proof and can be replayed, or nothing, in
/// which case the stretch is thrown away and never reaches a player.
class Verifier {
  const Verifier({this.mostStates = 400000});

  final int mostStates;

  /// How finely the runner's height and speed are rounded when deciding
  /// whether two states are the same.
  ///
  /// Coarse enough that the search converges, fine enough that two states it
  /// calls the same really do play out the same: a hundredth of a tile is well
  /// under the width of the runner's foot.
  static const _grain = 100;

  Passable check(Ground ground) {
    final start = _Node(run: Run.on(ground), from: null, held: false);
    final seen = <String>{_mark(start.run)};

    var edge = <_Node>[start];
    var looked = 0;

    while (edge.isNotEmpty && looked < mostStates) {
      final next = <_Node>[];
      for (final node in edge) {
        looked++;
        // Not holding first, so the line that comes back is the laziest one
        // that works. Held first and the search jumps its way along a flat
        // field, which is a perfectly good way through and a useless proof:
        // what a stretch is worth knowing is the fewest presses it needs, not
        // the most.
        for (final holding in const [false, true]) {
          final after = node.run.step(holding: holding);
          final reached = _Node(run: after, from: node, held: holding);

          // Standing on the last tile. The goal is being *on the ground*
          // there, not merely past it: a stretch is joined to the next one,
          // and a runner who leaves this one mid-jump arrives in the next one
          // somewhere its own proof knows nothing about. Ending each proof
          // standing still is what makes chaining them safe.
          if (after.column >= ground.length - 1 && after.onGround) {
            return Passable(
              through: true,
              holds: reached.holds,
              looked: looked,
              gaveUp: false,
            );
          }
          if (after.isOver) continue;

          final mark = _mark(after);
          if (!seen.add(mark)) continue;
          next.add(reached);
        }
      }
      edge = next;
    }

    return Passable(
      through: false,
      holds: const [],
      looked: looked,
      gaveUp: looked >= mostStates,
    );
  }

  /// What a state is, for a search that must not visit it twice.
  ///
  /// The step number is part of it because the world moves forwards on its
  /// own: the same height and speed two steps apart are two different places
  /// on the stretch. Everything else is rounded.
  static String _mark(Run run) => '${run.steps}|'
      '${(run.y * _grain).round()}|'
      '${(run.rise * _grain).round()}|'
      '${run.held}';
}

/// One state in the search, and how it was reached.
class _Node {
  const _Node({required this.run, required this.from, required this.held});

  final Run run;
  final _Node? from;

  /// Whether the button was held on the step that led here.
  final bool held;

  /// The steps the button was held on, all the way back to the start.
  List<int> get holds {
    final steps = <int>[];
    _Node? at = this;
    while (at != null && at.from != null) {
      if (at.held) steps.add(at.run.steps - 1);
      at = at.from;
    }
    return steps.reversed.toList();
  }
}

/// Plays a stretch with the button held on exactly those steps.
///
/// The other half of the proof. A list of step numbers is worth nothing unless
/// playing it really does reach the end, and this is what a test uses to find
/// out — and what the game uses to show a stretch playing itself behind the
/// title.
Run playWith(Ground ground, List<int> holds) {
  final held = holds.toSet();
  var run = Run.on(ground);
  while (!run.isOver) {
    run = run.step(holding: held.contains(run.steps));
  }
  return run;
}
