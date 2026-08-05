/// One climb: two words, and the fewest rungs between them.
///
/// The pair is the level. There is nothing else to it — no board to lay out
/// and nothing hidden — so a name on top of the two words would be a name for
/// something the player is already looking at.
class Climb {
  const Climb({required this.from, required this.to, required this.rungs});

  final String from;
  final String to;

  /// The fewest steps there are between them.
  ///
  /// Not an estimate and not a good score somebody managed. A test walks the
  /// whole list of words outwards from one end and fails if the shortest way
  /// through is not this number, so the target is the truth.
  final int rungs;

  int get letters => from.length;

  @override
  String toString() => '$from to $to in $rungs';
}

/// The climbs, in the order they are met.
///
/// Picked by hand out of what tool/find_ladders.dart turned up. What the tool
/// cannot judge is whether a word is one anybody would think of: a ladder
/// whose shortest way through goes by a word nobody knows reads as impossible
/// however short it is, and that is a decision rather than a measurement.
class Climbs {
  const Climbs._();

  static const all = <Climb>[
    Climb(from: 'rake', to: 'cons', rungs: 4),
    Climb(from: 'dewy', to: 'bins', rungs: 4),
    Climb(from: 'bush', to: 'fire', rungs: 5),
    Climb(from: 'perm', to: 'bets', rungs: 5),
    Climb(from: 'furl', to: 'lust', rungs: 5),
    Climb(from: 'halt', to: 'whet', rungs: 5),
    Climb(from: 'shed', to: 'tame', rungs: 6),
    Climb(from: 'oils', to: 'sees', rungs: 6),
    Climb(from: 'defy', to: 'lama', rungs: 7),
    Climb(from: 'gown', to: 'give', rungs: 7),
  ];

  static int get count => all.length;

  static Climb at(int which) => all[which.clamp(0, all.length - 1)];
}
