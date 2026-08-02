/// One column of the world, a tile wide.
///
/// Everything the runner can meet is one of these three. There is no fourth
/// kind on purpose: a game whose obstacles are all combinations of a pit, a
/// step and a spike is a game a player understands in ten seconds and can then
/// be surprised by for an hour.
class Tile {
  const Tile._({required this.top, required this.spiked});

  /// Plain ground at the bottom.
  static const flat = Tile._(top: 0, spiked: false);

  /// Nothing at all. Falling into one is the end of the run.
  static const pit = Tile._(top: _nothing, spiked: false);

  /// Ground with a spike standing on it.
  static const spike = Tile._(top: 0, spiked: true);

  /// A step up, [high] tiles above the ground. Landable on top, fatal from
  /// the side.
  const Tile.step(int high) : top = high, spiked = false;

  static const _nothing = -1000;

  /// How high the standable surface is, in tiles.
  final int top;

  final bool spiked;

  bool get isPit => top == _nothing;
  bool get isFlat => top == 0 && !spiked;

  @override
  bool operator ==(Object other) =>
      other is Tile && other.top == top && other.spiked == spiked;

  @override
  int get hashCode => Object.hash(top, spiked);

  @override
  String toString() => isPit
      ? '_'
      : spiked
          ? '^'
          : top == 0
              ? '.'
              : '$top';
}

/// A stretch of world: the tiles, in order.
class Ground {
  Ground(List<Tile> tiles) : tiles = List.unmodifiable(tiles);

  /// A stretch written down, for tests and for the fixed pieces the game is
  /// built from. `.` flat, `_` pit, `^` spike, a digit a step that high.
  factory Ground.of(String written) => Ground([
        for (final mark in written.split(''))
          switch (mark) {
            '.' => Tile.flat,
            '_' => Tile.pit,
            '^' => Tile.spike,
            _ => Tile.step(int.parse(mark)),
          },
      ]);

  final List<Tile> tiles;

  int get length => tiles.length;

  /// The tile at a place, or flat ground past the end. Past the end is flat
  /// because a run that gets there has finished the stretch and should not
  /// then fall through the floor.
  Tile at(int column) =>
      column < 0 || column >= tiles.length ? Tile.flat : tiles[column];

  Ground operator +(Ground other) => Ground([...tiles, ...other.tiles]);

  @override
  String toString() => tiles.map((tile) => '$tile').join();
}
