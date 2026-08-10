import 'net.dart';

/// Who is playing which part.
enum Part {
  /// Cuts a wire each turn, and wins when nothing joins the stations.
  cutter,

  /// Braces a wire each turn, and wins when braced wire alone joins them.
  linesman,
}

/// What the search says about a position: who wins it, and how soon.
class Verdict {
  const Verdict({required this.cutterWins, required this.inMoves});

  final bool cutterWins;

  /// How many moves the whole rest of the game takes with both sides playing
  /// as well as they can: the winner hurrying, the loser dragging it out.
  final int inMoves;
}

/// Plays the wire game out, both parts, perfectly.
///
/// A position is nothing but which wires are cut, which are braced, and whose
/// turn it is, so the whole game is settled by searching over those and
/// keeping every answer. A net of a dozen wires has at most a few hundred
/// thousand positions and most are never reached.
///
/// The winner hurries and the loser drags: among winning moves the search
/// takes the one that ends soonest, and among losing ones the one that lasts
/// longest, so a par on a round is a promise about the whole game and the
/// machine never gives anything away.
class Game {
  Game(this.net);

  final Net net;

  final _known = <int, Verdict>{};

  int _keyOf(int cut, int braced, Part turn) =>
      (cut * (1 << net.many) + braced) * 2 + (turn == Part.cutter ? 1 : 0);

  /// Who wins from here with both sides playing as well as they can.
  Verdict settle(int cut, int braced, Part turn) {
    if (!net.anythingJoins(cut)) {
      return const Verdict(cutterWins: true, inMoves: 0);
    }
    if (net.bracedJoin(braced)) {
      return const Verdict(cutterWins: false, inMoves: 0);
    }

    final key = _keyOf(cut, braced, turn);
    final known = _known[key];
    if (known != null) return known;

    Verdict? best;
    for (var wire = 0; wire < net.many; wire++) {
      final bit = 1 << wire;
      if ((cut & bit) != 0 || (braced & bit) != 0) continue;

      final after = turn == Part.cutter
          ? settle(cut | bit, braced, Part.linesman)
          : settle(cut, braced | bit, Part.cutter);
      final mine = after.cutterWins == (turn == Part.cutter);
      final candidate = Verdict(
        cutterWins: after.cutterWins,
        inMoves: after.inMoves + 1,
      );

      if (best == null) {
        best = candidate;
        continue;
      }
      final bestMine = best.cutterWins == (turn == Part.cutter);
      if (mine && !bestMine) {
        best = candidate;
      } else if (mine == bestMine) {
        final sooner = candidate.inMoves < best.inMoves;
        if (mine ? sooner : !sooner) best = candidate;
      }
    }

    // No wire left to touch: the stations are still joined by loose wire and
    // nothing braced joins them. Nobody can move, which cannot happen on a
    // net where every wire ends up cut or braced; treat it as the cutter
    // failing, since the line was never cut.
    best ??= const Verdict(cutterWins: false, inMoves: 0);
    _known[key] = best;
    return best;
  }

  /// The move to make from here for whoever's turn it is: winning and soonest
  /// when the position is won, longest-lasting when it is lost.
  int moveFrom(int cut, int braced, Part turn) {
    Verdict? best;
    var chosen = -1;

    for (var wire = 0; wire < net.many; wire++) {
      final bit = 1 << wire;
      if ((cut & bit) != 0 || (braced & bit) != 0) continue;

      final after = turn == Part.cutter
          ? settle(cut | bit, braced, Part.linesman)
          : settle(cut, braced | bit, Part.cutter);
      final mine = after.cutterWins == (turn == Part.cutter);
      final candidate = Verdict(
        cutterWins: after.cutterWins,
        inMoves: after.inMoves + 1,
      );

      if (best == null) {
        best = candidate;
        chosen = wire;
        continue;
      }
      final bestMine = best.cutterWins == (turn == Part.cutter);
      if (mine && !bestMine) {
        best = candidate;
        chosen = wire;
      } else if (mine == bestMine) {
        final sooner = candidate.inMoves < best.inMoves;
        if (mine ? sooner : !sooner) {
          best = candidate;
          chosen = wire;
        }
      }
    }
    return chosen;
  }
}
