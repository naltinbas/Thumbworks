/// What is walking down the lane.
enum Walker {
  /// The ordinary one. Everything is balanced against it.
  drifter(
    name: 'drifter',
    life: 100,
    pace: 1.5,
    worth: 8,
    costs: 1,
  ),

  /// Quick and thin. Punishes a lane held by one slow heavy tower.
  runner(
    name: 'runner',
    life: 55,
    pace: 3.1,
    worth: 10,
    costs: 1,
  ),

  /// Slow and thick. Punishes a lane held by fast weak towers.
  lumberer(
    name: 'lumberer',
    life: 420,
    pace: 0.95,
    worth: 26,
    costs: 3,
  ),

  /// Shrugs off a share of every hit, so raw damage matters less against it
  /// than how often it is hit.
  warded(
    name: 'warded',
    life: 220,
    pace: 1.35,
    worth: 22,
    costs: 2,
    shrugs: 0.45,
  );

  const Walker({
    required this.name,
    required this.life,
    required this.pace,
    required this.worth,
    required this.costs,
    this.shrugs = 0,
  });

  final String name;

  /// How much damage it takes to put one down.
  final int life;

  /// Cells a second.
  final double pace;

  /// Embers for killing it.
  final int worth;

  /// What it costs the keep if it gets out.
  final int costs;

  /// The share of each hit it shrugs off, before anything else.
  final double shrugs;
}

/// What can be built.
enum Tower {
  /// Cheap, quick, short. Two of these beat one of anything else against
  /// runners and lose badly to a lumberer.
  spark(
    name: 'Spark',
    cost: 40,
    reach: 2.2,
    hits: 14,
    every: 0.42,
  ),

  /// Slow and heavy. One shot is worth eleven of a spark's, and it misses
  /// three runners while it winds up.
  forge(
    name: 'Forge',
    cost: 95,
    reach: 2.8,
    hits: 155,
    every: 2.1,
  ),

  /// Does almost nothing on its own. Halves the pace of everything in reach,
  /// which is worth more than any amount of damage at a corner where the lane
  /// doubles back on itself.
  frost(
    name: 'Frost',
    cost: 70,
    reach: 2.4,
    hits: 6,
    every: 0.9,
    slows: 0.5,
    slowsFor: 1.4,
  );

  const Tower({
    required this.name,
    required this.cost,
    required this.reach,
    required this.hits,
    required this.every,
    this.slows = 0,
    this.slowsFor = 0,
  });

  final String name;

  /// Embers to build.
  final int cost;

  /// How far it shoots, in cells.
  final double reach;

  /// Damage a shot.
  final int hits;

  /// Seconds between shots.
  final double every;

  /// How much of a walker's pace it takes away, as a share.
  final double slows;

  /// For how long, in seconds.
  final double slowsFor;

  /// What the next level costs, and what it gives.
  ///
  /// One level up, not five. A defence game with a long upgrade ladder is a
  /// game about spreadsheets; the interesting decision is where to build, and
  /// a second level is enough to make "here again" a real answer to it.
  int get upgradeCost => (cost * 1.6).round();
  int get upgradedHits => (hits * 1.85).round();
  double get upgradedReach => reach + 0.5;
}
