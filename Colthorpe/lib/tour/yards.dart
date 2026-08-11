import 'yard.dart';

/// The yards that ship.
///
/// Two of them cannot be ridden, and they are impossible in two different
/// ways, which is the pairing the game is for. The Wrong Gate falls to an
/// argument anyone can check on the grass: a round that touches all
/// twenty five paddocks alternates colours and so has thirteen of the
/// colour it starts on, and the yard has only twelve light paddocks. The
/// Cross Paddocks has no such argument, eight dark and eight light, and
/// falls only to the walk of every ride there is.
class Yards {
  const Yards._();

  static final List<Yard> all = [
    Yard(
      name: 'The Little Yard',
      width: 3,
      height: 4,
      closed: false,
      possible: true,
    ),
    Yard(
      name: 'The Cross Paddocks',
      width: 4,
      height: 4,
      closed: false,
      possible: false,
      note: 'Eight dark and eight light: the colours have nothing to say '
          'against this yard. Only the walk of every ride proves there is '
          'none, and it does.',
    ),
    Yard(
      name: 'The Five Yard',
      width: 5,
      height: 5,
      closed: false,
      possible: true,
      starts: 0,
      note: 'Thirteen dark paddocks, twelve light, and every jump changes '
          'colour: a full round must start and end on dark. The gate is at '
          'a dark corner for a reason.',
    ),
    Yard(
      name: 'The Wrong Gate',
      width: 5,
      height: 5,
      closed: false,
      possible: false,
      starts: 1,
      note: 'The gate opens on a light paddock. A round of twenty five '
          'alternates colours, so it needs thirteen of the colour it '
          'starts on, and the yard has twelve. Count them: that is the '
          'whole proof.',
    ),
    Yard(
      name: 'The Full Round',
      width: 6,
      height: 6,
      closed: true,
      possible: true,
      starts: 0,
      note: 'A closed round needs as many dark paddocks as light, and '
          'thirty six splits even: the colours allow it, and the walk '
          'finds it.',
    ),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number.clamp(0, all.length - 1)];
}
