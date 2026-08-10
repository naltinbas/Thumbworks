import 'yard.dart';

/// The yards that ship.
///
/// The pars go 3, 7, 15, 31, 63: each yard is one stone more and each par is
/// twice the last and one, which is the whole story of this puzzle and the
/// reason the six stone yard is sixty three moves of honest work.
class Yards {
  const Yards._();

  static const all = <Yard>[
    Yard(name: 'Two Stones', stones: 2, fewest: 3),
    Yard(name: 'Three Stones', stones: 3, fewest: 7),
    Yard(name: 'Four Stones', stones: 4, fewest: 15),
    Yard(name: 'Five Stones', stones: 5, fewest: 31),
    Yard(name: 'The Whole Stack', stones: 6, fewest: 63),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number.clamp(0, all.length - 1)];
}
