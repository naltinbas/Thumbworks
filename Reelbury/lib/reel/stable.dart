import 'hall.dart';

/// Two people on opposite sides who would both rather have each other than
/// what they have got. A pairing with one of these in it will not hold.
class Blocking {
  const Blocking(this.caller, this.dancer);

  final int caller;
  final int dancer;

  @override
  bool operator ==(Object other) =>
      other is Blocking && other.caller == caller && other.dancer == dancer;

  @override
  int get hashCode => Object.hash(caller, dancer);

  @override
  String toString() => 'caller $caller and dancer $dancer';
}

/// Pairing the two sides up so that nobody wants to swap.
///
/// A pairing holds — is *stable* — when there is no pair on opposite sides
/// who would both rather have each other than what they have got. That is
/// the whole rule, and it is the only rule: nobody is asked to be happy, only
/// to have no better offer that would be taken.
class Stable {
  const Stable._();

  /// Every pair who would rather have each other, in a pairing given as the
  /// dancer each caller has.
  static List<Blocking> blocking(Hall hall, List<int> pairing) {
    final has = List<int>.filled(hall.count, -1);
    for (var caller = 0; caller < hall.count; caller++) {
      if (pairing[caller] >= 0) has[pairing[caller]] = caller;
    }

    final found = <Blocking>[];
    for (var caller = 0; caller < hall.count; caller++) {
      for (var dancer = 0; dancer < hall.count; dancer++) {
        if (pairing[caller] == dancer) continue;

        // Anybody unpaired would rather have somebody than nobody, which is
        // what makes a half-finished pairing show its own gaps.
        final callerWould = pairing[caller] < 0 ||
            hall.callerPrefers(caller, dancer, pairing[caller]);
        final dancerWould =
            has[dancer] < 0 || hall.dancerPrefers(dancer, caller, has[dancer]);
        if (callerWould && dancerWould) found.add(Blocking(caller, dancer));
      }
    }
    return found;
  }

  static bool holds(Hall hall, List<int> pairing) =>
      !pairing.contains(-1) && blocking(hall, pairing).isEmpty;

  /// The pairing everybody on the asking side likes best of the ones that
  /// hold, by asking in turn.
  ///
  /// Gale and Shapley, 1962. Each caller asks the dancers in their own order;
  /// a dancer holds the best offer so far and turns the rest away; anybody
  /// turned away asks the next one down their list. It cannot go round for
  /// ever, because every ask is one a caller never makes again, and it cannot
  /// end with anybody spare, because a dancer who has been asked never goes
  /// back to nobody.
  ///
  /// So there is always a pairing that holds. That is not a hope about these
  /// boards, it is a proof about all of them, and it is why this game can
  /// promise that every board has an answer.
  static List<int> byAsking(Hall hall, {bool callersAsk = true}) {
    final asking = callersAsk ? hall.callers : hall.dancers;
    final held = List<int>.filled(hall.count, -1);
    final next = List<int>.filled(hall.count, 0);
    final free = [for (var who = 0; who < hall.count; who++) who];

    while (free.isNotEmpty) {
      final who = free.removeLast();
      final wanted = asking[who][next[who]++];
      final holding = held[wanted];

      if (holding < 0) {
        held[wanted] = who;
        continue;
      }
      final keeps = callersAsk
          ? hall.dancerPrefers(wanted, who, holding)
          : hall.callerPrefers(wanted, who, holding);
      if (keeps) {
        held[wanted] = who;
        free.add(holding);
      } else {
        free.add(who);
      }
    }

    // Answered as the dancer each caller has, whichever side did the asking.
    if (!callersAsk) return held;
    final pairing = List<int>.filled(hall.count, -1);
    for (var dancer = 0; dancer < hall.count; dancer++) {
      pairing[held[dancer]] = dancer;
    }
    return pairing;
  }

  /// Every pairing that holds, found by trying all of them.
  ///
  /// Only for small halls and only for tests and the tool: it is n factorial,
  /// which is fine at six and hopeless at twelve. What it is for is checking
  /// the asking against something that shares none of its ideas.
  static List<List<int>> allThatHold(Hall hall) {
    final found = <List<int>>[];
    final pairing = List<int>.filled(hall.count, -1);
    final taken = List<bool>.filled(hall.count, false);

    void walk(int caller) {
      if (caller == hall.count) {
        if (holds(hall, pairing)) found.add(List.of(pairing));
        return;
      }
      for (var dancer = 0; dancer < hall.count; dancer++) {
        if (taken[dancer]) continue;
        taken[dancer] = true;
        pairing[caller] = dancer;
        walk(caller + 1);
        pairing[caller] = -1;
        taken[dancer] = false;
      }
    }

    walk(0);
    return found;
  }

  /// Whether there is only one pairing that holds.
  ///
  /// Two ways of asking that: both sides ask and get the same answer, or
  /// count them all. The first is a theorem — the pairings that hold have a
  /// best one for each side, and one pairing when those two are the same —
  /// and the second is a search. A test holds them against each other.
  static bool isOnlyOne(Hall hall) {
    final asked = byAsking(hall);
    final answered = byAsking(hall, callersAsk: false);
    for (var caller = 0; caller < hall.count; caller++) {
      if (asked[caller] != answered[caller]) return false;
    }
    return true;
  }
}
