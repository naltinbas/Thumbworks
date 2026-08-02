import 'kinds.dart';

/// One group inside a wave: how many of what, and how fast they come.
class Group {
  const Group(this.walker, this.count, {this.every = 0.8, this.after = 0});

  final Walker walker;
  final int count;

  /// Seconds between one and the next.
  final double every;

  /// Seconds after the wave starts before the first of them arrives.
  final double after;
}

/// A wave: what comes, and what putting it down is worth.
class Wave {
  const Wave(this.groups, {required this.pays});

  final List<Group> groups;

  /// Embers for surviving it, on top of what the walkers were worth.
  final int pays;

  int get walkers => groups.fold(0, (sum, group) => sum + group.count);

  /// How long until the last of them has set off.
  double get lasts => groups.fold(0, (longest, group) {
        final end = group.after + group.every * (group.count - 1);
        return end > longest ? end : longest;
      });
}

/// The waves, in order.
///
/// Twenty of them, written down rather than generated. The shape of a defence
/// game is the order its problems arrive in — runners before there is anything
/// quick enough to catch them, a lumberer just as the sparks that have been
/// working start to look weak — and a generator produces a list with no such
/// moments in it.
///
/// The numbers were not chosen by feel. tool/dryrun.dart plays the whole thing
/// against a fixed strategy and reports which wave it dies on; the table below
/// is what came out of moving numbers until a careful player gets through and
/// a careless one does not.
class Waves {
  const Waves._();

  static const all = <Wave>[
    Wave([Group(Walker.drifter, 6, every: 1.0)], pays: 22),
    Wave([Group(Walker.drifter, 10, every: 0.85)], pays: 24),
    Wave([
      Group(Walker.drifter, 8, every: 0.8),
      Group(Walker.runner, 3, every: 0.7, after: 7),
    ], pays: 26),
    Wave([Group(Walker.runner, 9, every: 0.55)], pays: 28),
    Wave([
      Group(Walker.drifter, 12, every: 0.6),
      Group(Walker.lumberer, 1, after: 4),
    ], pays: 32),
    Wave([
      Group(Walker.runner, 10, every: 0.5),
      Group(Walker.drifter, 8, every: 0.7, after: 3),
    ], pays: 34),
    Wave([Group(Walker.lumberer, 3, every: 2.4)], pays: 38),
    Wave([
      Group(Walker.warded, 4, every: 1.4),
      Group(Walker.drifter, 10, every: 0.6, after: 2),
    ], pays: 40),
    Wave([
      Group(Walker.runner, 14, every: 0.42),
      Group(Walker.lumberer, 2, every: 3, after: 5),
    ], pays: 44),
    Wave([
      Group(Walker.warded, 7, every: 1.1),
      Group(Walker.runner, 8, every: 0.5, after: 4),
    ], pays: 48),
    Wave([
      Group(Walker.lumberer, 5, every: 2.0),
      Group(Walker.runner, 10, every: 0.45, after: 3),
    ], pays: 52),
    Wave([
      Group(Walker.drifter, 24, every: 0.35),
      Group(Walker.warded, 5, every: 1.2, after: 6),
    ], pays: 56),
    Wave([
      Group(Walker.warded, 10, every: 0.9),
      Group(Walker.lumberer, 3, every: 2.5, after: 4),
    ], pays: 60),
    Wave([
      Group(Walker.runner, 22, every: 0.3),
      Group(Walker.warded, 6, every: 1.0, after: 5),
    ], pays: 64),
    Wave([
      Group(Walker.lumberer, 7, every: 1.8),
      Group(Walker.warded, 6, every: 1.1, after: 2),
    ], pays: 70),
    Wave([
      Group(Walker.drifter, 30, every: 0.28),
      Group(Walker.lumberer, 4, every: 2.2, after: 6),
      Group(Walker.runner, 12, every: 0.35, after: 9),
    ], pays: 76),
    Wave([
      Group(Walker.warded, 14, every: 0.75),
      Group(Walker.runner, 14, every: 0.35, after: 4),
    ], pays: 82),
    Wave([
      Group(Walker.lumberer, 9, every: 1.5),
      Group(Walker.warded, 8, every: 0.9, after: 3),
    ], pays: 88),
    Wave([
      Group(Walker.runner, 30, every: 0.24),
      Group(Walker.lumberer, 6, every: 1.8, after: 5),
      Group(Walker.warded, 8, every: 0.8, after: 8),
    ], pays: 96),
    Wave([
      Group(Walker.lumberer, 12, every: 1.2),
      Group(Walker.warded, 16, every: 0.6, after: 2),
      Group(Walker.runner, 20, every: 0.3, after: 5),
    ], pays: 120),
  ];

  static int get count => all.length;

  /// Everything that walks, if every wave is let through.
  static int get everyWalker =>
      all.fold(0, (sum, wave) => sum + wave.walkers);
}
