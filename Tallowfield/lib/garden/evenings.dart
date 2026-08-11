import 'evening.dart';

/// The evenings that ship.
///
/// The first four are the code doing what it does: no complaint, one
/// hedge, two, all three, and the bed the complaints cut out holds the
/// changed lantern every time. The Double Draught is the boundary told
/// honestly: two lanterns changed, and the tallies, which cannot know,
/// point with perfect confidence at a third. Reading them right and
/// being wrong is the whole lesson of that evening.
class Evenings {
  const Evenings._();

  static final List<Evening> all = [
    Evening(
      name: 'The First Draught',
      planted: 0x07,
      snuffed: const [1],
      note: 'One hedge complains, so the lantern stands in that hedge and '
          'neither of the others: the bed inside hedge A alone, and lamp '
          'one stands in it.',
    ),
    Evening(
      name: 'The Shared Bed',
      planted: 0x1E,
      snuffed: const [7],
      note: 'All three hedges complain at once, and only one bed lies '
          'inside all three.',
    ),
    Evening(
      name: 'The Quiet Garden',
      planted: 0x7F,
      snuffed: const [],
      note: 'Every hedge even is the gardener\'s own planting: nothing to '
          'find, and saying so is the right reading.',
    ),
    Evening(
      name: 'The Fourth Bed',
      planted: 0x33,
      snuffed: const [6],
    ),
    Evening(
      name: 'The Double Draught',
      planted: 0x2D,
      snuffed: const [2, 5],
      note: 'The draught was at two lanterns tonight. Their two beds '
          'cancel and complain as one third bed: the tallies point at a '
          'lantern the draught never touched. One fault the hedges find; '
          'two they mistake, and no reading of three tallies can do '
          'better.',
    ),
  ];

  static int get count => all.length;

  static Evening at(int number) => all[number.clamp(0, all.length - 1)];
}
