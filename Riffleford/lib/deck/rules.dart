/// The law of the deck.
///
/// A deck laid in a repeating pattern, red black red black, or
/// three kinds round and round. Cut it anywhere, turn the cut-off
/// packet over so it reads backwards, and riffle the two piles
/// together any way you please, a card from either pile at every
/// drop. Gilbreath's principle, 1958, says every block of the
/// pattern's length in the riffled deck holds one card of each
/// kind, however sloppily you riffled: the two piles read the
/// pattern in opposite directions from the cut, so at the start
/// of every block their top cards differ, whichever way the last
/// block went. Skip the turning over and an even cut breaks it.
class Rules {
  Rules(this.deck, {required this.cut, required this.turned, required this.kinds});

  /// The deck top to bottom, one letter a card: R, B, G.
  final String deck;

  /// How many cards the first pile takes.
  final int cut;

  /// Whether the first pile is turned over, top for bottom.
  final bool turned;

  /// The pattern's length: how many kinds, and the block size.
  final int kinds;

  int get length => deck.length;

  /// The first pile, top to bottom, turned over or not.
  String get first {
    final packet = deck.substring(0, cut);
    return turned ? packet.split('').reversed.join() : packet;
  }

  /// The second pile, top to bottom.
  String get second => deck.substring(cut);

  /// The riffled deck a run of drops deals: 'A' takes the next
  /// card of the first pile, 'B' of the second.
  String dealt(String drops) {
    final out = StringBuffer();
    var a = 0, b = 0;
    for (final drop in drops.split('')) {
      if (drop == 'A') {
        out.write(first[a++]);
      } else {
        out.write(second[b++]);
      }
    }
    return out.toString();
  }

  /// Whether each full block of the dealt cards holds every kind.
  List<bool> blocks(String cards) => [
        for (var i = 0; i + kinds <= cards.length; i += kinds)
          cards.substring(i, i + kinds).split('').toSet().length == kinds,
      ];

  /// Whether a full riffle deals every block mixed.
  bool allMixed(String drops) =>
      drops.length == length && blocks(dealt(drops)).every((yes) => yes);

  /// Every full riffle, walked; calls [visit] with the drops.
  void riffles(void Function(String) visit) {
    final drops = <String>[];
    void go(int a, int b) {
      if (a == cut && b == length - cut) {
        visit(drops.join());
        return;
      }
      if (a < cut) {
        drops.add('A');
        go(a + 1, b);
        drops.removeLast();
      }
      if (b < length - cut) {
        drops.add('B');
        go(a, b + 1);
        drops.removeLast();
      }
    }

    go(0, 0);
  }

  /// How many full riffles there are, and how many deal every
  /// block mixed.
  (int, int) sweep() {
    var all = 0, mixed = 0;
    riffles((drops) {
      all++;
      if (allMixed(drops)) mixed++;
    });
    return (all, mixed);
  }

  /// The riffles that deal some block unmixed.
  int unmixedRiffles() {
    final (all, mixed) = sweep();
    return all - mixed;
  }

  /// The count of riffles by arithmetic: the cut chosen from the
  /// deck's places, no walking.
  int riffleCount() {
    var top = 1, bottom = 1;
    for (var i = 0; i < cut; i++) {
      top *= length - i;
      bottom *= i + 1;
    }
    return top ~/ bottom;
  }

  /// The tops-differ invariant for two kinds: at the start of every
  /// block, while both piles have cards, their top cards differ;
  /// walked along every riffle.
  bool topsDifferAlways() {
    if (kinds != 2) return false;
    var holds = true;
    riffles((drops) {
      var a = 0, b = 0;
      for (var step = 0; step < length; step++) {
        if (step % kinds == 0 && a < cut && b < length - cut) {
          if (first[a] == second[b]) holds = false;
        }
        if (drops[step] == 'A') {
          a++;
        } else {
          b++;
        }
      }
    });
    return holds;
  }

  /// Whether the two piles read the pattern in opposite directions
  /// from the cut: the first pile, turned, is the deck read upward
  /// from the cut, and the second is the deck read downward.
  bool readOppositeWays() {
    if (!turned) return false;
    for (var i = 0; i < cut; i++) {
      if (first[i] != deck[cut - 1 - i]) return false;
    }
    return second == deck.substring(cut);
  }

  /// The first full riffle the sweep finds that deals every block
  /// mixed, or null.
  String? landing() {
    String? found;
    riffles((drops) {
      if (found == null && allMixed(drops)) found = drops;
    });
    return found;
  }
}
