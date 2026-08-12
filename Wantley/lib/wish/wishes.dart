import 'wish.dart';

/// The five wish lists that ship.
///
/// Every number here is checked before the bake: the sweep of
/// all 64 and 1,024 treadings, Erdos and Gallai's arithmetic,
/// Havel and Hakimi's build, and tool/check_wishes.dart refuses
/// the lot if anything disagrees.
class Wishes {
  static const all = [
    Wish(
      name: 'The Four Ones',
      wishes: [1, 1, 1, 1],
      ways: 3,
      note: 'A one-wish farm takes exactly one path, so the '
          'four farms pair off, and four farms pair off three '
          'ways.',
    ),
    Wish(
      name: 'The Round Wish',
      wishes: [2, 2, 2, 2, 2],
      ways: 12,
      note: 'Every landing is one ring through all five farms, '
          'and twelve is exactly the count of rings on five.',
    ),
    Wish(
      name: 'The Seven Ways',
      wishes: [3, 3, 2, 2, 2],
      ways: 7,
      note: 'Every landing spends exactly six paths: half the '
          'wish sum, the handshake law made to pay.',
    ),
    Wish(
      name: 'The One Way',
      wishes: [4, 4, 3, 3, 2],
      ways: 1,
      note: 'The one landing is exactly what the top-down deal '
          'builds: wire the biggest wish to everyone, then the '
          'next, and nothing is left to choose.',
    ),
    Wish(
      name: 'The Three Threes',
      wishes: [3, 3, 3, 1],
      ways: 0,
      note: 'The wish sum is even and still it fails: evenness '
          'is not the whole law. Three farms wanting every '
          'neighbour tread paths to each other and all three '
          'to the last farm, handing it three against its '
          'wished one.',
    ),
  ];

  static int get count => all.length;

  static Wish at(int number) => all[number];
}
