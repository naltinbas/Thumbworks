import 'frac.dart';
import 'rules.dart';

/// One ask: what the loop of levers is to come to.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'climb': any loop that gains in the long run; 'famous': the loop of
  /// Parrondo's telling; 'four': the best a loop of four can do;
  /// 'best': the best any loop can do; 'one': one lever and no other,
  /// still gaining, which never happens.
  final String kind;

  /// How many loops land it, from the sweep.
  final int ways;

  /// The loop the pointer works towards, the cheapest the sweep found;
  /// empty when nothing lands the ask.
  final String aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The climb of the loop Parrondo told it with, A once and B twice.
  static Frac get famous => Frac.of(2416, 35601);

  /// The best climb any loop of twelve slots or fewer has.
  static Frac get best => Frac.of(3613392, 47747645);

  /// The best a loop of four slots has.
  static Frac get bestFour => Frac.of(4, 163);

  /// Whether [loop] lands the ask.
  bool meets(String loop) {
    if (!Rules.valid(loop)) return false;
    final climb = Rules.climb(loop);
    switch (kind) {
      case 'climb':
        return climb > Frac.zero;
      case 'famous':
        return climb == famous;
      case 'four':
        return loop.length == 4 && climb == bestFour;
      case 'best':
        return climb == best;
      default:
        return Rules.oneLever(loop) && climb > Frac.zero;
    }
  }

  /// The fewest taps the ask takes from the opening loop, or null when
  /// nothing lands it.
  int? get fewest => winnable ? Rules.cost(Rules.opening, aim) : null;

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'climb':
        return 'build a loop whose purse climbs in the long run';
      case 'famous':
        return 'build the loop Parrondo told it with, climbing 2416/35601 a round';
      case 'four':
        return 'build a loop of four slots that climbs as fast as a four can';
      case 'best':
        return 'build the loop that climbs faster than any other';
      default:
        return 'fill the loop with one lever and come out ahead';
    }
  }
}
