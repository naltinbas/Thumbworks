import 'house.dart';

/// The five houses that ship.
///
/// Every number here is checked before the bake: the walks,
/// the all-even law and the circling law over every dialling,
/// and tool/check_windows.dart refuses the lot if anything
/// disagrees.
class Houses {
  static const all = [
    House(
      name: 'The One Turn',
      count: 4,
      asked: 1,
      ways: 7,
      note: 'Seven diallings go dark at once: the four windows '
          'all alike and lit, each difference paying nought.',
    ),
    House(
      name: 'The Common Lot',
      count: 4,
      asked: 4,
      ways: 2384,
      note: 'Four turns is the commonest road to darkness: '
          '2,384 of the 4,096 diallings walk it, more than '
          'half.',
    ),
    House(
      name: 'The Seven Turns',
      count: 4,
      asked: 7,
      ways: 128,
      note: 'Seven is the house\'s whole reach: 128 diallings '
          'walk it full, nought, one, three, seven among them, '
          'each face doubling its gap.',
    ),
    House(
      name: 'The Three Alike',
      count: 3,
      asked: 1,
      ways: 7,
      note: 'Three windows go dark only from all alike: seven '
          'lit diallings rest in one turn, and no other three '
          'ever rests.',
    ),
    House(
      name: 'The Three Turns',
      count: 3,
      asked: 3,
      ways: 0,
      note: 'The parities tread a ring: nought-one-one turns '
          'to one-nought-one turns to one-one-nought and round '
          'again, never dark. Only all-alike escapes, and it '
          'rests in one.',
    ),
  ];

  static int get count => all.length;

  static House at(int number) => all[number];
}
