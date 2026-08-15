import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Four Hamlets',
      kinds: [0, 0, 0, 0],
      lanes: [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)],
      size: 3,
      start: [(0, 0), (2, 2), (2, 0), (0, 2)],
      ways: 192,
      settings: 3024,
      note: 'Four hamlets each laned to each is six lanes, and Euler allows 3v - 6, '
          'six exactly, so the green is as full as a clear green can be: 192 of '
          'the 3,024 placings on the three-by-three lay it clear, the first with '
          'a hamlet inside the triangle of the other three.',
    ),
    Level(
      name: 'The Two and the Three',
      kinds: [0, 0, 1, 1, 1],
      lanes: [(0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4)],
      size: 3,
      start: [(1, 0), (1, 2), (0, 1), (2, 1), (0, 0)],
      ways: 912,
      settings: 15120,
      note: 'Two hamlets each laned to three others is six lanes over five hamlets, '
          'and with the hamlets of two kinds Euler allows 2v - 4, six exactly: 912 '
          'of the 15,120 placings on the three-by-three lay it clear.',
    ),
    Level(
      name: 'The Five Less One',
      kinds: [0, 0, 0, 0, 0],
      lanes: [(0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)],
      size: 4,
      start: [(0, 0), (3, 0), (3, 3), (0, 3), (1, 1)],
      ways: 1200,
      settings: 524160,
      note: 'Five hamlets each laned to each is ten lanes, one over Euler\'s 3v - 6, '
          'and no placing of the five on the four-by-four lays all ten clear, none '
          'of 524,160; with one lane left out, nine, 1,200 placings do.',
    ),
    Level(
      name: 'The Three and the Three Less One',
      kinds: [0, 0, 0, 1, 1, 1],
      lanes: [(0, 4), (0, 5), (1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5)],
      size: 4,
      start: [(0, 0), (1, 0), (2, 0), (0, 3), (1, 3), (2, 3)],
      ways: 26432,
      settings: 5765760,
      note: 'Eight lanes over six hamlets of two kinds is Euler\'s 2v - 4 exactly, '
          'and 26,432 of the 5,765,760 placings on the four-by-four lay them clear.',
    ),
    Level(
      name: 'The Three and the Three',
      kinds: [0, 0, 0, 1, 1, 1],
      lanes: [(0, 3), (0, 4), (0, 5), (1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5)],
      size: 4,
      start: [(0, 0), (1, 0), (2, 0), (0, 3), (1, 3), (2, 3)],
      ways: 0,
      settings: 5765760,
      note: 'Three hamlets each laned to three is nine lanes over six hamlets of '
          'two kinds, and every ring of lanes on such a green has four lanes at '
          'least, so with f faces 4f is at most 2e, and Euler\'s v - e + f = 2 '
          'makes e at most 2v - 4, eight: the ninth lane always crosses. None of '
          'the 5,765,760 placings on the four-by-four is clear, nor any of the '
          '127,512,000 on the five-by-five.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
