import 'batch.dart';

/// The batches that ship.
///
/// Every par came out of the full walk before it was written down. The
/// First Batch and the Even Turn have their gap counts exactly equal to the
/// answer, so the floor a player can count carries the whole number. The
/// Slack Batch is there for the opposite reason: its gaps say one fewer
/// than the walk knows is needed, and the game says so out loud, because a
/// floor that is sometimes slack is worth meeting where it is slack. The
/// Hand's Way is the batch where the griddle hand's two-flips-a-cake
/// routine spends two more than the fewest, and the Tall Order wants a
/// flip for every cake it has.
class Batches {
  const Batches._();

  static final List<Batch> all = [
    Batch(name: 'The First Batch', cakes: const [3, 2, 4, 1], fewest: 3),
    Batch(name: 'The Even Turn', cakes: const [4, 2, 5, 3, 1], fewest: 5),
    Batch(name: 'The Slack Batch', cakes: const [4, 5, 3, 1, 2], fewest: 4),
    Batch(name: "The Hand's Way", cakes: const [6, 5, 1, 4, 2, 3], fewest: 3),
    Batch(name: 'The Tall Order', cakes: const [6, 4, 7, 3, 1, 5, 2], fewest: 7),
  ];

  static int get count => all.length;

  static Batch at(int number) => all[number.clamp(0, all.length - 1)];
}
