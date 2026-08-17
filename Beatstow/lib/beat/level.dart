import 'rules.dart';

/// One ask: a rack of throws, to be laid on the beats so that no two
/// balls come down together.
class Level {
  const Level({
    required this.name,
    required this.rack,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The throws to be laid, sorted. There are as many as there are
  /// beats, so every beat takes one.
  final List<int> rack;

  /// How many of the rack's layings juggle. The sweep's number, and the
  /// checker refuses the bake if it drifts.
  final int ways;

  /// The taps from the empty ring to a laying that juggles; null when
  /// none does. A throw takes two taps, one to pick it up and one to lay
  /// it, so it is twice the beats and never a search.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  /// How many different layings the rack has at all.
  int get layings => Rules.orderings(rack).length;

  /// The throws added up.
  int get total => Rules.total(rack);

  /// Whether the throws go round the beats evenly, which is the same as
  /// asking whether the rack can juggle at all.
  bool get evens => total % Rules.beats == 0;

  /// The balls such a rack would keep up, when it keeps any.
  int get balls => total ~/ Rules.beats;

  bool get winnable => ways > 0;

  /// Whether this laying lands the ask.
  bool meets(List<int> laid) {
    if (laid.length != Rules.beats) return false;
    for (final t in laid) {
      if (t < 0) return false;
    }
    final want = [...rack]..sort();
    final got = [...laid]..sort();
    for (var i = 0; i < want.length; i++) {
      if (want[i] != got[i]) return false;
    }
    return Rules.juggles(laid);
  }

  /// The task, told in words.
  String get task =>
      'lay ${rack.join(', ')} on the beats so that no two balls come down '
      'together';
}
