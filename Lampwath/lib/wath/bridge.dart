/// One walker: a name, and how long the bridge takes them.
class Walker {
  const Walker(this.name, this.minutes);

  final String name;
  final int minutes;
}

/// A night at the bridge: the walkers on the near bank, one lantern, and a
/// bridge that carries two at a time.
///
/// Whoever crosses must carry the lantern, at most two may cross together,
/// and two together go at the slower one's pace. That is all the rules there
/// are, and the eighteenth minute of the famous four is lost or saved
/// entirely inside them.
class Bridge {
  const Bridge({
    required this.name,
    required this.walkers,
    required this.fewest,
    this.ferryDoes = false,
  });

  final String name;
  final List<Walker> walkers;

  /// The fewest minutes that get everybody over. Written down here as well as
  /// worked out, so a test can hold the two against each other.
  final int fewest;

  /// Whether ferrying everybody over with the fastest walker is itself the
  /// fewest here. On the boundary bridges it is, and the label says so.
  final bool ferryDoes;

  int get count => walkers.length;

  /// Everybody on the far bank, as bits.
  int get everyone => (1 << count) - 1;
}
