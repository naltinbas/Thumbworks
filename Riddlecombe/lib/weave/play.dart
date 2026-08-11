import 'mesh.dart';
import 'rules.dart';

/// A weave being woven. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.mesh, this.rules, this.weave, this.before);

  Play.of(Mesh mesh) : this._(mesh, Rules(mesh.strands), const [], null);

  final Mesh mesh;
  final Rules rules;

  /// The combs placed so far, in their columns.
  final List<(int, int)> weave;

  final Play? before;

  int get placed => weave.length;

  int get room => mesh.combs - placed;

  /// The grists that still run foul.
  List<int> get unsettled => rules.unsettled(weave);

  /// Whether every grist runs clean: the riddle, and the win.
  bool get isClean => unsettled.isEmpty;

  bool get outOfCombs => !isClean && room == 0;

  /// Whether two strands may take a comb.
  bool mayComb(int upper, int lower) =>
      !isClean &&
      room > 0 &&
      upper >= 0 &&
      lower >= 0 &&
      upper != lower &&
      upper < mesh.strands &&
      lower < mesh.strands;

  /// Places a comb between two strands, either order.
  Play comb(int one, int other) {
    if (!mayComb(one, other)) return this;
    final upper = one < other ? one : other;
    final lower = one < other ? other : one;
    return Play._(mesh, rules, [...weave, (upper, lower)], this);
  }

  Play get back => before ?? this;

  /// Whether a clean riddle is still within the frame's combs.
  bool get canStill => rules.canStill(weave, room);

  /// A comb that keeps the clean riddle in reach, or null.
  (int, int)? get next => isClean ? null : rules.next(weave, room);

  /// The first grist that still runs foul, or null.
  int? get foul {
    final left = unsettled;
    return left.isEmpty ? null : left.first;
  }
}
