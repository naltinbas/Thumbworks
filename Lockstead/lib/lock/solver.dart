import 'dart:typed_data';

import 'lock.dart';
import 'marks.dart';

/// What a guess would leave behind.
class Worst {
  const Worst({required this.guess, required this.most, required this.couldBe});

  final int guess;

  /// The size of the largest group it could leave. The number that matters:
  /// whatever the code is, this many possibilities at most survive the guess.
  final int most;

  /// Whether the guess is itself one of the codes still possible, and so
  /// might open the lock outright.
  final bool couldBe;
}

/// Picks guesses, and proves how many are ever needed.
///
/// The rule is the obvious one once it is said out loud: of every code you
/// could name, name the one whose worst outcome leaves the fewest
/// possibilities standing. It is not a heuristic — it is the guess that is
/// best against an adversary who gets to choose the code after seeing it, and
/// that is exactly the guarantee worth having.
class Solver {
  Solver(this.marks);

  final Marks marks;

  Lock get lock => marks.lock;

  /// The guess that leaves the least behind, whatever the answer turns out to
  /// be.
  ///
  /// Ties go to a guess that could itself be the code, because that one might
  /// end the game this turn and the other one certainly will not.
  Worst best(Int32List could) {
    if (could.length == 1) {
      return Worst(guess: could.first, most: 1, couldBe: true);
    }

    final possible = Uint8List(lock.codes);
    for (final code in could) {
      possible[code] = 1;
    }

    final counts = Int32List(marks.width);
    var bestGuess = could.first;
    var bestMost = could.length + 1;
    var bestCouldBe = false;

    for (var guess = 0; guess < lock.codes; guess++) {
      counts.fillRange(0, counts.length, 0);
      var most = 0;
      for (var i = 0; i < could.length; i++) {
        final mark = marks.at(could[i], guess);
        final now = ++counts[mark];
        if (now > most) most = now;
        // Nothing that has already lost can win. Most guesses are hopeless
        // and this is what stops the loop reading the whole set to find out.
        if (most > bestMost) break;
      }
      if (most > bestMost) continue;

      final couldBe = possible[guess] == 1;
      if (most < bestMost || (couldBe && !bestCouldBe)) {
        bestGuess = guess;
        bestMost = most;
        bestCouldBe = couldBe;
      }
    }

    return Worst(guess: bestGuess, most: bestMost, couldBe: bestCouldBe);
  }

  /// How many guesses this way of playing ever needs, and how they fall out.
  ///
  /// Not a sample and not an average over random secrets. The strategy is a
  /// tree — one guess at the top, one branch for every mark it can come back
  /// with, the same question again down each branch — and walking that tree
  /// once answers for every code at the same time. Every code in the lock is
  /// somewhere in it, so the deepest leaf is the promise.
  Depths deepest({int give = 12}) {
    final byDepth = <int, int>{};
    var deepest = 0;

    void walk(Int32List could, int taken) {
      if (could.isEmpty) return;
      if (taken >= give) {
        byDepth[give] = (byDepth[give] ?? 0) + could.length;
        deepest = give;
        return;
      }

      final pick = best(could).guess;
      // Naming the code is a guess like any other, and it is the one that
      // opens the lock.
      final opens = could.contains(pick) ? 1 : 0;
      if (opens == 1) {
        byDepth[taken + 1] = (byDepth[taken + 1] ?? 0) + 1;
        if (taken + 1 > deepest) deepest = taken + 1;
      }

      final seen = <int>{};
      for (var i = 0; i < could.length; i++) {
        final mark = marks.at(could[i], pick);
        if (mark == marks.allRight) continue;
        if (!seen.add(mark)) continue;
        walk(marks.narrow(could, pick, mark), taken + 1);
      }
    }

    walk(marks.everything, 0);
    return Depths(deepest: deepest, byDepth: byDepth);
  }
}

/// How many guesses a lock takes, code by code.
class Depths {
  const Depths({required this.deepest, required this.byDepth});

  /// The most guesses any code ever needs. The promise on the box.
  final int deepest;

  /// How many codes take each number of guesses.
  final Map<int, int> byDepth;

  int get codes => byDepth.values.fold(0, (all, one) => all + one);

  double get average {
    var total = 0;
    byDepth.forEach((depth, many) => total += depth * many);
    return total / codes;
  }

  @override
  String toString() {
    final keys = byDepth.keys.toList()..sort();
    return [for (final k in keys) '$k: ${byDepth[k]}'].join('  ');
  }
}
