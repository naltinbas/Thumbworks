import 'call.dart';
import 'wager.dart';

/// The tables that ship.
///
/// The first two are the bet as it is worked on strangers: you call, the
/// house calls after you, and the house's rule wins at two to one or
/// better whatever you do. The Head Run holds you to the worst call there
/// is, seven to one against. The Turned Table is the game with the chairs
/// swapped, the one table you should always play. The Even Table is the
/// only fair reply the house can make, and the why says why it is fair.
class Wagers {
  const Wagers._();

  static final List<Wager> all = [
    Wager(
      name: 'The First Wager',
      stakes: 1,
      note: 'The house calls the other side of your middle flip, then your '
          'first two. Your call ends where its call begins, so most runs '
          'that would finish yours have already finished the house\'s.',
    ),
    Wager(name: 'The Long Run', stakes: 3),
    Wager(
      name: 'The Head Run',
      stakes: 1,
      forced: Call(7),
      note: 'Three heads is the worst call on the board: the house calls '
          'tails-heads-heads and wins seven times in eight. The only run '
          'that beats it is heads off the very first flip.',
    ),
    Wager(
      name: 'The Turned Table',
      stakes: 3,
      theyCallFirst: true,
      theirFixedCall: Call(5),
      note: 'The chairs are swapped: the house has called and you reply. '
          'Calling second is the whole game, and now the two-to-one odds '
          'are yours.',
    ),
    Wager(
      name: 'The Even Table',
      stakes: 3,
      evenTable: true,
      note: 'The house answers with your call turned over, heads for '
          'tails and tails for heads. Swap every coin in the world and '
          'the two calls trade places, so neither can be the better: the '
          'one fair reply there is.',
    ),
  ];

  static int get count => all.length;

  static Wager at(int number) => all[number.clamp(0, all.length - 1)];
}
