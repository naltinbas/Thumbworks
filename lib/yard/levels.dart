import 'yard.dart';

/// One yard, written out as a picture.
///
/// `#` is a wall, `.` a mark, `$` a crate, `*` a crate already on a mark,
/// `@` the hauler and `+` the hauler standing on a mark. Anything else is
/// floor.
///
/// Written by hand. A yard is one idea — a corner you can only come at from
/// behind, a crate that has to be moved before another one can be — and
/// nothing that generates yards generates ideas.
class Level {
  const Level({
    required this.name,
    required this.about,
    required this.rows,
    required this.par,
  });

  final String name;

  /// The idea of the yard, in a line. Said out loud on the list of yards,
  /// because a wall of little pictures tells you nothing about which one you
  /// want to play.
  final String about;

  final List<String> rows;

  /// The fewest shoves this yard can be finished in.
  ///
  /// Not a designer's guess and not a good score somebody once got. A test
  /// searches the whole yard for the shortest way through and fails if this
  /// is not the answer, so the number a player is trying to match is true.
  final int par;

  int get across =>
      rows.map((row) => row.length).reduce((a, b) => a > b ? a : b);

  int get down => rows.length;

  /// Everything about the yard that never moves.
  Ground get ground {
    final walls = <int>{};
    final marks = <int>{};
    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < across; column++) {
        // A row written short is walled to the end of the line, so a picture
        // does not have to be padded out with spaces nobody can see.
        final what = column < rows[row].length ? rows[row][column] : '#';
        final at = row * across + column;
        if (what == '#') walls.add(at);
        if (what == '.' || what == '*' || what == '+') marks.add(at);
      }
    }
    return Ground(across: across, down: down, walls: walls, marks: marks);
  }

  /// Where everything starts.
  Yard get start {
    final crates = <int>[];
    var hauler = 0;
    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < rows[row].length; column++) {
        final what = rows[row][column];
        final at = row * across + column;
        if (what == r'$' || what == '*') crates.add(at);
        if (what == '@' || what == '+') hauler = at;
      }
    }
    return Yard.of(ground, hauler, crates);
  }

  int get crates => start.crates.length;
}

/// The yards, in the order they are met.
class Levels {
  const Levels._();

  static const all = <Level>[
    Level(
      name: 'The first one',
      about: 'A crate, a mark, and nothing in the way.',
      par: 2,
      rows: [
        '#######',
        '#     #',
        '#  .  #',
        '#     #',
        '#  \$  #',
        '#  @  #',
        '#     #',
        '#######',
      ],
    ),
    Level(
      name: 'Out of the way',
      about: 'One of them is standing where the other has to go.',
      par: 3,
      rows: [
        '########',
        '#      #',
        '#  ##  #',
        '# .\$.  #',
        '#  \$   #',
        '#  @   #',
        '#      #',
        '########',
      ],
    ),
    Level(
      name: 'Round the corner',
      about: 'It has to turn, and it can only turn from behind.',
      par: 4,
      rows: [
        '#######',
        '#.    #',
        '#     #',
        '#  \$  #',
        '#  @  #',
        '#     #',
        '#######',
      ],
    ),
    Level(
      name: 'Round the back',
      about: 'The way in is not the way it looks.',
      par: 4,
      rows: [
        '########',
        '#      #',
        '# #### #',
        '# #  # #',
        '# # .# #',
        '# #  # #',
        '# ##   #',
        '#  \$   #',
        '#  @   #',
        '########',
      ],
    ),
    Level(
      name: 'Both of them',
      about: 'Two crates, two marks, and no room to be careless.',
      par: 6,
      rows: [
        '########',
        '#      #',
        '# .  . #',
        '#      #',
        '#  \$\$  #',
        '#  @   #',
        '#      #',
        '########',
      ],
    ),
    Level(
      name: 'Out of the pen',
      about: 'Get it out first. Worry about the mark after.',
      par: 6,
      rows: [
        '#########',
        '#       #',
        '# ##### #',
        '# #   # #',
        '# # \$ # #',
        '# #   # #',
        '# ##  ###',
        '#  @   .#',
        '#########',
      ],
    ),
    Level(
      name: 'Three deep',
      about: 'A row of three, and the middle one is the problem.',
      par: 6,
      rows: [
        '########',
        '#      #',
        '# ...  #',
        '#      #',
        '# \$\$\$  #',
        '#  @   #',
        '#      #',
        '########',
      ],
    ),
    Level(
      name: 'The pinch',
      about: 'Two gaps, and the wrong one costs you the yard.',
      par: 6,
      rows: [
        '########',
        '#      #',
        '#  .   #',
        '## ## ##',
        '#  \$   #',
        '#  @   #',
        '#   .  #',
        '#  \$   #',
        '#      #',
        '########',
      ],
    ),
    Level(
      name: 'The long way round',
      about: 'The short way is a wall.',
      par: 7,
      rows: [
        '########',
        '#      #',
        '# .    #',
        '####  ##',
        '#      #',
        '# \$ @  #',
        '#      #',
        '########',
      ],
    ),
    Level(
      name: 'Wrong side first',
      about: 'Neither will move until the other has.',
      par: 7,
      rows: [
        '########',
        '#      #',
        '#  .   #',
        '#      #',
        '#  \$   #',
        '#  \$   #',
        '#  @   #',
        '#      #',
        '#  .   #',
        '########',
      ],
    ),
    Level(
      name: 'The yard',
      about: 'Four corners, four crates, and one of you.',
      par: 8,
      rows: [
        '#########',
        '#       #',
        '# .   . #',
        '#  \$ \$  #',
        '#   @   #',
        '#  \$ \$  #',
        '# .   . #',
        '#       #',
        '#########',
      ],
    ),
    Level(
      name: 'Last out',
      about: 'Five in a row. The last one out is the hard one.',
      par: 10,
      rows: [
        '#########',
        '#       #',
        '# ..... #',
        '#       #',
        '# \$\$\$\$\$ #',
        '#   @   #',
        '#       #',
        '#########',
      ],
    ),
  ];

  static int get count => all.length;

  static Level at(int which) => all[which.clamp(0, all.length - 1)];
}
