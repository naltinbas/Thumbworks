import 'hand.dart';
import 'rules.dart';

/// Five stones being dialled. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.hand, this.faces, this.moves, this.before);

  factory Play.of(Hand hand) =>
      Play._(hand, List.of(hand.opens), 0, null);

  /// A play stood at a dialling, for the mark and the tests.
  factory Play.standing(Hand hand, List<int> faces) =>
      Play._(hand, List.of(faces), 1, null);

  final Hand hand;

  /// The five faces as dialled.
  final List<int> faces;

  /// Taps taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless hand admits it.
  static const gaveUpAt = 15;

  List<(int, int, int)> get thirds => Rules.thirds(faces);

  bool get isDone => thirds.length == hand.asked;

  bool get gaveUp => !hand.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a stone turns at all.
  bool turns(int stone) =>
      !isOver &&
      stone >= 0 &&
      stone < Rules.stones &&
      (hand.locked == null || hand.locked!.$1 != stone);

  /// Taps a stone: its face steps up and wraps past six.
  Play tapAt(int stone) {
    if (!turns(stone)) return this;
    final turned = List.of(faces);
    turned[stone] = turned[stone] % Rules.faces + 1;
    return Play._(hand, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The stone the show-me points at: the first turn of a
  /// fewest-taps road to the asking, or null when none lands.
  int? get next {
    if (isOver) return null;
    List<int>? bestRoad;
    var fewest = 1 << 30;
    Rules.hands((aim) {
      if (Rules.thirds(aim).length != hand.asked) return;
      var taps = 0;
      for (var stone = 0; stone < Rules.stones; stone++) {
        taps += (aim[stone] - faces[stone]) % Rules.faces;
      }
      if (taps < fewest) {
        fewest = taps;
        bestRoad = List.of(aim);
      }
    }, locked: hand.locked);
    final aim = bestRoad;
    if (aim == null) return null;
    for (var stone = 0; stone < Rules.stones; stone++) {
      if (aim[stone] != faces[stone]) return stone;
    }
    return null;
  }
}
