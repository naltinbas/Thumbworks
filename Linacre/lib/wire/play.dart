import 'game.dart';
import 'net.dart';
import 'rounds.dart';
import 'webs.dart';

/// One exchange: the player's wire, and the machine's answer, or -1 when the
/// game ended before the machine could move.
class Exchange {
  const Exchange(this.mine, this.theirs);

  final int mine;
  final int theirs;
}

/// A round part played.
class Play {
  Play._(this.round, this.game, this.exchanges);

  factory Play.of(Round round, Game game) => Play._(round, game, const []);

  final Round round;

  /// The settled search, kept for as long as the round is open.
  final Game game;

  /// Everything that has happened, in order.
  final List<Exchange> exchanges;

  Net get net => round.net;

  Part get mine => round.part;

  Part get theirs => mine == Part.cutter ? Part.linesman : Part.cutter;

  /// The wires cut so far, as bits.
  int get cut {
    var bits = 0;
    for (final exchange in exchanges) {
      final wire = mine == Part.cutter ? exchange.mine : exchange.theirs;
      if (wire >= 0) bits |= 1 << wire;
    }
    return bits;
  }

  /// The wires braced so far, as bits.
  int get braced {
    var bits = 0;
    for (final exchange in exchanges) {
      final wire = mine == Part.linesman ? exchange.mine : exchange.theirs;
      if (wire >= 0) bits |= 1 << wire;
    }
    return bits;
  }

  bool isCut(int wire) => (cut & (1 << wire)) != 0;
  bool isBraced(int wire) => (braced & (1 << wire)) != 0;
  bool isFree(int wire) => !isCut(wire) && !isBraced(wire);

  /// The machine's latest wire, or -1.
  int get theirLast => exchanges.isEmpty ? -1 : exchanges.last.theirs;

  /// How many moves the player has made.
  int get made => exchanges.length;

  /// Whether the line is down: nothing joins the stations any more.
  bool get isDown => !net.anythingJoins(cut);

  /// Whether the line is held: braced wire alone joins the stations.
  bool get isHeld => net.bracedJoin(braced);

  bool get isOver => isDown || isHeld;

  /// Whether the player won.
  bool get won => mine == Part.cutter ? isDown : isHeld;

  bool get isFewest =>
      won && round.fewest != null && made <= round.fewest!;

  /// Whether the player can still force the win from here, and in how many
  /// more of their own moves. Null when they cannot.
  int? get canStillWinIn {
    if (isOver) return won ? 0 : null;
    final verdict = game.settle(cut, braced, mine);
    final iWin = verdict.cutterWins == (mine == Part.cutter);
    if (!iWin) return null;
    return (verdict.inMoves + 1) ~/ 2;
  }

  /// The best the whole round can now come to, in the player's own moves.
  int? get couldFinishIn {
    final left = canStillWinIn;
    return left == null ? null : made + left;
  }

  /// The player touches a free wire: cut it or brace it, and the machine
  /// answers at once unless that ended it.
  Play touch(int wire) {
    if (isOver || wire < 0 || wire >= net.many || !isFree(wire)) return this;

    final myCut = mine == Part.cutter ? cut | (1 << wire) : cut;
    final myBraced = mine == Part.linesman ? braced | (1 << wire) : braced;

    final over = mine == Part.cutter
        ? !net.anythingJoins(myCut)
        : net.bracedJoin(myBraced);
    if (over) {
      return Play._(round, game, [...exchanges, Exchange(wire, -1)]);
    }

    final answer = game.moveFrom(myCut, myBraced, theirs);
    return Play._(round, game, [...exchanges, Exchange(wire, answer)]);
  }

  Play get back => exchanges.isEmpty
      ? this
      : Play._(round, game, exchanges.sublist(0, exchanges.length - 1));

  Play get again => Play.of(round, game);

  /// Asked. The wire to touch next that still wins as soon as the round can
  /// now be won, or null when it cannot.
  int? get next {
    if (isOver || canStillWinIn == null) return null;
    return game.moveFrom(cut, braced, mine);
  }

  /// Two webs over what is left of the net, with the braced wire shrunk away,
  /// spoken in the original net's wires. When these exist the linesman cannot
  /// lose from here, whoever he is.
  TwoWebs? get websNow {
    final small = net.shrunk(cut, braced);
    if (small.net.count < 2) return null;
    final pair = Webs.findTwoWebs(small.net);
    if (pair == null) return null;

    int backOut(int bits) {
      var wires = 0;
      for (var wire = 0; wire < small.net.many; wire++) {
        if ((bits & (1 << wire)) != 0) wires |= 1 << small.wireOf[wire];
      }
      return wires;
    }

    return TwoWebs(
      posts: pair.posts,
      one: backOut(pair.one),
      other: backOut(pair.other),
    );
  }
}
