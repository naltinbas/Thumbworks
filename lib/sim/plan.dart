import 'field.dart';
import 'kinds.dart';
import 'run.dart';
import 'waves.dart';

/// One thing a player would do, and when.
class Order {
  const Order.build(this.tower, this.on, {required this.beforeWave})
      : upgrade = false,
        sell = false;

  const Order.upgrade(this.on, {required this.beforeWave})
      : tower = null,
        upgrade = true,
        sell = false;

  const Order.sell(this.on, {required this.beforeWave})
      : tower = null,
        upgrade = false,
        sell = true;

  final Tower? tower;
  final Cell on;
  final bool upgrade;
  final bool sell;

  /// Which wave this is done before, counting from zero. Everything for a wave
  /// happens while it is waiting to be called, which is when a player would do
  /// it.
  final int beforeWave;

  Run applyTo(Run run) {
    if (sell) return run.sell(on);
    if (upgrade) return run.upgrade(on);
    return run.build(tower!, on);
  }

  /// Whether this could ever be carried out, embers aside.
  ///
  /// Worth separating from cannot-afford-yet, because they want opposite
  /// treatment: a plan that cannot afford something waits for it, and a plan
  /// that asks for a tower on the path is a plan with a typo in it. The first
  /// version treated both as "wait", and a single order on a path cell stalled
  /// the whole queue for the rest of the game while the embers piled up.
  bool isPossibleIn(Run run) {
    final standing = run.towerOn(on);
    if (sell) return standing != null;
    if (upgrade) return standing != null && standing.canUpgrade;
    return standing == null && Field.only.canBuildOn(on);
  }

  @override
  String toString() => sell
      ? 'sell $on'
      : upgrade
          ? 'upgrade $on'
          : 'build ${tower!.name} on $on';
}

/// A way of playing, written down.
///
/// A plan is a list of orders and nothing else — no reactions, no conditions.
/// That is deliberate: the point of these is to be a fixed thing the game can
/// be measured against, and a plan that adapts is a plan that hides a change
/// in the numbers by playing around it.
///
/// The orders are a queue, and the plan saves up. When its turn comes and
/// there are not enough embers, the plan waits rather than skipping ahead to
/// something cheaper — which is what a player with a plan does, and which
/// means a plan that asks for more than the game pays out gets slower rather
/// than quietly turning into a different plan.
class Plan {
  const Plan(this.name, this.orders);

  final String name;
  final List<Order> orders;

  /// Plays the whole game, carrying out what it can afford between waves and
  /// calling the next one when it can do no more.
  ///
  /// [until] stops it early. That is what the screenshots use: a position half
  /// way through wave seven with six towers up and things walking is not
  /// something worth posing by hand, and a posed one would be a position no
  /// run ever reached.
  Run play({int mostSteps = 400000, bool Function(Run)? until}) {
    var run = Run.fresh();
    var next = 0;

    while (!run.isOver && run.steps < mostSteps) {
      if (until != null && until(run)) return run;
      if (run.waiting) {
        // Everything due by now that the embers will stretch to, in order,
        // stopping at the first thing they will not.
        while (next < orders.length && orders[next].beforeWave <= run.wave) {
          final order = orders[next];
          if (!order.isPossibleIn(run)) {
            throw StateError('$name: $order can never be carried out');
          }
          final after = order.applyTo(run);
          // Not affordable yet. Wait for it rather than skipping to something
          // cheaper: a plan that reorders itself is measuring itself.
          if (identical(after, run)) break;
          run = after;
          next++;
        }
        run = run.callWave();
        // A wave with nothing in it would leave the run waiting forever.
        if (run.waiting) break;
      }
      run = run.step();
    }
    return run;
  }

  /// What the towers standing at the end cost to get there, for the report.
  int spent(Run run) => run.built.fold(
        0,
        (total, tower) =>
            total +
            tower.kind.cost +
            (tower.level > 1 ? tower.kind.upgradeCost : 0),
      );

  /// The three plans the numbers are measured against.
  ///
  /// What is wanted is for [held] to get through, [thin] to die somewhere in
  /// the middle, and [silly] to die early. A game the careless player also
  /// wins is a game with nothing in it.
  static const all = [held, thin, silly];

  /// A careful player: a shopping list, bought in order as the embers come
  /// in.
  ///
  /// Almost everything here is [beforeWave] zero, which is not a mistake. The
  /// pacing that matters is what the game pays out, not a schedule written
  /// next to the list — the first version had one order a wave and died on
  /// eleven with twelve hundred embers in hand, which measured the schedule
  /// rather than the game.
  static const held = Plan('careful', [
    Order.build(Tower.spark, Cell(3, 1), beforeWave: 0),
    Order.build(Tower.spark, Cell(2, 3), beforeWave: 0),
    Order.build(Tower.spark, Cell(0, 4), beforeWave: 0),
    Order.build(Tower.frost, Cell(2, 4), beforeWave: 0),
    Order.build(Tower.spark, Cell(3, 4), beforeWave: 0),
    Order.build(Tower.forge, Cell(2, 6), beforeWave: 0),
    Order.build(Tower.spark, Cell(6, 4), beforeWave: 0),
    Order.build(Tower.spark, Cell(6, 6), beforeWave: 0),
    Order.build(Tower.frost, Cell(6, 7), beforeWave: 0),
    Order.build(Tower.forge, Cell(3, 7), beforeWave: 0),
    Order.upgrade(Cell(3, 1), beforeWave: 0),
    Order.build(Tower.spark, Cell(1, 9), beforeWave: 0),
    Order.build(Tower.spark, Cell(3, 9), beforeWave: 0),
    Order.build(Tower.forge, Cell(4, 10), beforeWave: 0),
    Order.build(Tower.frost, Cell(3, 10), beforeWave: 0),
    Order.upgrade(Cell(2, 6), beforeWave: 0),
    Order.build(Tower.spark, Cell(5, 10), beforeWave: 0),
    Order.build(Tower.forge, Cell(5, 12), beforeWave: 0),
    Order.upgrade(Cell(3, 7), beforeWave: 0),
    Order.upgrade(Cell(4, 10), beforeWave: 0),
    Order.build(Tower.forge, Cell(7, 10), beforeWave: 0),
    Order.upgrade(Cell(5, 12), beforeWave: 0),
    Order.upgrade(Cell(2, 4), beforeWave: 0),
    Order.upgrade(Cell(6, 7), beforeWave: 0),
    Order.upgrade(Cell(7, 10), beforeWave: 0),
    Order.upgrade(Cell(3, 4), beforeWave: 0),
    Order.upgrade(Cell(2, 3), beforeWave: 0),
    Order.upgrade(Cell(0, 4), beforeWave: 0),
    Order.upgrade(Cell(6, 4), beforeWave: 0),
    Order.upgrade(Cell(6, 6), beforeWave: 0),
    Order.upgrade(Cell(1, 9), beforeWave: 0),
    Order.upgrade(Cell(3, 9), beforeWave: 0),
    Order.upgrade(Cell(5, 10), beforeWave: 0),
    Order.upgrade(Cell(3, 10), beforeWave: 0),
  ]);

  /// Half as many towers, all in one place. A player who builds a good corner
  /// and then stops thinking about the rest of the lane.
  static const thin = Plan('one good corner', [
    Order.build(Tower.spark, Cell(3, 1), beforeWave: 0),
    Order.build(Tower.spark, Cell(2, 3), beforeWave: 0),
    Order.build(Tower.spark, Cell(0, 4), beforeWave: 0),
    Order.build(Tower.frost, Cell(2, 4), beforeWave: 0),
    Order.build(Tower.forge, Cell(2, 6), beforeWave: 0),
    Order.upgrade(Cell(2, 6), beforeWave: 0),
    Order.upgrade(Cell(3, 1), beforeWave: 0),
    Order.upgrade(Cell(2, 3), beforeWave: 0),
    Order.build(Tower.forge, Cell(0, 6), beforeWave: 0),
    Order.upgrade(Cell(0, 6), beforeWave: 0),
    Order.upgrade(Cell(2, 4), beforeWave: 0),
    Order.upgrade(Cell(0, 4), beforeWave: 0),
  ]);

  /// Sparks, in the corners of the field, where almost nothing walks past.
  /// The thing somebody does on their first go.
  static const silly = Plan('sparks everywhere', [
    Order.build(Tower.spark, Cell(0, 0), beforeWave: 0),
    Order.build(Tower.spark, Cell(8, 0), beforeWave: 0),
    Order.build(Tower.spark, Cell(0, 12), beforeWave: 0),
    Order.build(Tower.spark, Cell(8, 12), beforeWave: 0),
    Order.build(Tower.spark, Cell(0, 6), beforeWave: 0),
    Order.build(Tower.spark, Cell(8, 6), beforeWave: 0),
  ]);

  /// How many waves a plan holds, which is the one number worth comparing.
  static int wavesHeld(Plan plan) => plan.play().wave;

  /// Whether the wave table is one a careful player can get through.
  static bool get careful => wavesHeld(held) >= Waves.count;
}
