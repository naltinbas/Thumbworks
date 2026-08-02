import 'cards.dart';
import 'deal.dart';

/// Where a card can be.
enum Where {
  /// One of the four holding places at the top left. One card each.
  cell,

  /// One of the four piles at the top right, built up by suit from the ace.
  home,

  /// One of the eight columns.
  column,
}

/// A move: some cards, from somewhere, to somewhere.
class Move {
  const Move({
    required this.from,
    required this.fromAt,
    required this.to,
    required this.toAt,
    this.cards = 1,
  });

  final Where from;

  /// Which cell, home or column.
  final int fromAt;

  final Where to;
  final int toAt;

  /// How many cards move. Only ever more than one from a column to a column.
  final int cards;

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.from == from &&
      other.fromAt == fromAt &&
      other.to == to &&
      other.toAt == toAt &&
      other.cards == cards;

  @override
  int get hashCode => Object.hash(from, fromAt, to, toAt, cards);

  @override
  String toString() =>
      '${_name(from)}$fromAt->${_name(to)}$toAt${cards > 1 ? ' x$cards' : ''}';

  static String _name(Where where) => switch (where) {
        Where.cell => 'cell',
        Where.home => 'home',
        Where.column => 'col',
      };
}

/// A position: what is in the cells, on the homes, and down the columns.
///
/// Immutable. Playing a move gives a new table, which is what lets undo be a
/// list and what lets the solver hold a position while it tries something.
class Table {
  Table._({
    required List<Card?> cells,
    required List<int> homes,
    required List<List<Card>> columns,
  })  : _cells = List.unmodifiable(cells),
        _homes = List.unmodifiable(homes),
        _columns = List.unmodifiable(
          columns.map(List<Card>.unmodifiable),
        );

  /// A numbered deal, laid out.
  factory Table.deal(int number) => Table._(
        cells: List<Card?>.filled(cellCount, null),
        homes: List<int>.filled(4, 0),
        columns: Deal.layout(number),
      );

  /// A position written down, for tests and for the odd fixed position.
  ///
  /// Columns are space-separated cards, cells are a list, homes are the top
  /// rank on each suit in the order clubs, diamonds, hearts, spades.
  factory Table.of({
    required List<String> columns,
    List<String?> cells = const [null, null, null, null],
    List<int> homes = const [0, 0, 0, 0],
  }) =>
      Table._(
        cells: [for (final face in cells) face == null ? null : Card.from(face)],
        homes: List<int>.from(homes),
        columns: [
          for (final line in columns)
            [
              for (final face in line.split(' '))
                if (face.isNotEmpty) Card.from(face),
            ],
        ],
      );

  static const cellCount = 4;
  static const columnCount = Deal.columns;

  final List<Card?> _cells;

  /// The top rank on each home, by suit index. Zero means empty.
  final List<int> _homes;

  final List<List<Card>> _columns;

  Card? cell(int at) => _cells[at];
  int home(Suit suit) => _homes[suit.index];
  List<Card> column(int at) => _columns[at];

  int get freeCells => _cells.where((card) => card == null).length;
  int get emptyColumns => _columns.where((column) => column.isEmpty).length;

  /// Every card home. Nothing else counts as winning.
  bool get isWon => _homes.every((rank) => rank == 13);

  /// How many cards are home, which is the one number worth showing.
  int get homeCount => _homes.fold(0, (sum, rank) => sum + rank);

  /// How many cards may be moved from one column to another at once.
  ///
  /// The rule everybody actually plays by. Moving a run of five is really
  /// four moves through the cells and one move of the bottom card, so what it
  /// costs is free cells, and an empty column doubles what those cells can
  /// carry because it can hold a run of its own on the way.
  ///
  /// [into] matters: an empty column being moved *into* cannot also be used as
  /// staging, which is the special case everyone forgets and which shows up as
  /// a move the game allows and the solver's own arithmetic does not.
  int canCarry({bool into = false}) {
    final spare = emptyColumns - (into ? 1 : 0);
    return (freeCells + 1) * (1 << (spare < 0 ? 0 : spare));
  }

  /// The run of cards at the end of a column that could move together: each
  /// sitting on the one before, down one and the other colour.
  int runAt(int at) {
    final column = _columns[at];
    if (column.isEmpty) return 0;
    var run = 1;
    for (var i = column.length - 1; i > 0; i--) {
      if (!column[i].sitsOn(column[i - 1])) break;
      run++;
    }
    return run;
  }

  bool _canGoHome(Card card) => _homes[card.suit.index] == card.rank - 1;

  bool _canGoOn(int at, Card card) {
    final column = _columns[at];
    if (column.isEmpty) return true;
    return card.sitsOn(column.last);
  }

  /// Whether this move is one the rules allow.
  bool allows(Move move) => moves.contains(move);

  /// Every move that could be played.
  ///
  /// Written to be read rather than to be fast, and then measured: the solver
  /// asks for this a few hundred thousand times a deal and it is not what
  /// takes the time.
  List<Move> get moves {
    final moves = <Move>[];

    // Out of the cells.
    for (var at = 0; at < cellCount; at++) {
      final card = _cells[at];
      if (card == null) continue;
      if (_canGoHome(card)) {
        moves.add(Move(
          from: Where.cell,
          fromAt: at,
          to: Where.home,
          toAt: card.suit.index,
        ));
      }
      for (var to = 0; to < columnCount; to++) {
        if (!_canGoOn(to, card)) continue;
        moves.add(
          Move(from: Where.cell, fromAt: at, to: Where.column, toAt: to),
        );
        // One empty column is the same as any other, so offering all of them
        // is offering the same move several times over.
        if (_columns[to].isEmpty) break;
      }
    }

    // Out of the columns.
    for (var from = 0; from < columnCount; from++) {
      final column = _columns[from];
      if (column.isEmpty) continue;
      final top = column.last;

      if (_canGoHome(top)) {
        moves.add(Move(
          from: Where.column,
          fromAt: from,
          to: Where.home,
          toAt: top.suit.index,
        ));
      }

      final free = _cells.indexOf(null);
      if (free >= 0) {
        moves.add(
          Move(from: Where.column, fromAt: from, to: Where.cell, toAt: free),
        );
      }

      final run = runAt(from);
      for (var to = 0; to < columnCount; to++) {
        if (to == from) continue;
        final onto = _columns[to];
        final room = canCarry(into: onto.isEmpty);

        var most = 0;
        for (var take = 1; take <= run && take <= room; take++) {
          final card = column[column.length - take];
          if (_canGoOn(to, card)) most = take;
        }
        if (most == 0) continue;

        // Moving a whole column into an empty one gets nowhere, and a solver
        // that is allowed to will do it forever.
        if (onto.isEmpty && most == column.length) continue;

        moves.add(Move(
          from: Where.column,
          fromAt: from,
          to: Where.column,
          toAt: to,
          cards: most,
        ));
        if (onto.isEmpty) break;
      }
    }

    return moves;
  }

  /// The table after a move.
  Table play(Move move) {
    final cells = List<Card?>.from(_cells);
    final homes = List<int>.from(_homes);
    final columns = [for (final column in _columns) List<Card>.from(column)];

    final taken = <Card>[];
    switch (move.from) {
      case Where.cell:
        taken.add(cells[move.fromAt]!);
        cells[move.fromAt] = null;
      case Where.home:
        // Nothing ever comes off a home. Cards go there to stay, and a game
        // that lets them come back is a game that never ends.
        throw ArgumentError('cards do not come off a home');
      case Where.column:
        final column = columns[move.fromAt];
        taken.addAll(column.sublist(column.length - move.cards));
        column.removeRange(column.length - move.cards, column.length);
    }

    switch (move.to) {
      case Where.cell:
        cells[move.toAt] = taken.single;
      case Where.home:
        homes[move.toAt] = taken.single.rank;
      case Where.column:
        columns[move.toAt].addAll(taken);
    }

    return Table._(cells: cells, homes: homes, columns: columns);
  }

  /// Every card that could go straight home right now, played.
  ///
  /// Only the ones that are safe: a card goes up only when nothing of the
  /// other colour still needs to sit on it. Sending everything up the moment
  /// it can is how a position that was winnable stops being winnable, because
  /// a five that has gone home is a five no black four can rest on.
  Table get tidied {
    var table = this;
    var again = true;
    while (again) {
      again = false;
      for (final move in table.moves) {
        if (move.to != Where.home) continue;
        final card = move.from == Where.cell
            ? table._cells[move.fromAt]!
            : table._columns[move.fromAt].last;
        if (!table._isSafeHome(card)) continue;
        table = table.play(move);
        again = true;
        break;
      }
    }
    return table;
  }

  /// Whether sending [card] home can never cost anything.
  ///
  /// It cannot if both of the other colour's cards one rank below are already
  /// home themselves, because then there is nothing left that would have
  /// wanted to sit on it. Aces and twos are always safe.
  bool _isSafeHome(Card card) {
    if (card.rank <= 2) return true;
    final wanted = card.rank - 1;
    for (final suit in Suit.values) {
      if (suit.black == card.black) continue;
      if (_homes[suit.index] < wanted) return false;
    }
    return true;
  }

  /// How much digging is left, roughly.
  ///
  /// For each suit, the card the foundation wants next, and how many cards are
  /// lying on top of it. It is the difference between a position that is one
  /// move from four aces and one where all four are at the bottom of a column,
  /// which nothing else here notices.
  int get buried {
    var total = 0;
    for (final suit in Suit.values) {
      final rank = _homes[suit.index] + 1;
      if (rank > 13) continue;
      final wanted = Card.of(suit, rank);
      for (final column in _columns) {
        final at = column.indexOf(wanted);
        if (at < 0) continue;
        total += column.length - at - 1;
        break;
      }
    }
    return total;
  }

  /// What this position is, for a solver that must not look at it twice.
  ///
  /// The cells are sorted and the columns are sorted, because which cell a
  /// card sits in and which order two identical columns are written in change
  /// nothing about the position. Without that, the same position is met again
  /// and again wearing different hats, and the search does the same work
  /// dozens of times over.
  String get fingerprint {
    final cells = [
      for (final card in _cells) card == null ? '--' : card.face,
    ]..sort();
    final columns = [
      for (final column in _columns) column.map((card) => card.face).join(),
    ]..sort();
    return '${cells.join()}|${_homes.join(',')}|${columns.join('/')}';
  }

  @override
  String toString() {
    final cells = [
      for (final card in _cells) card?.face ?? '..',
    ].join(' ');
    final homes = [
      for (final suit in Suit.values)
        _homes[suit.index] == 0
            ? '..'
            : Card.of(suit, _homes[suit.index]).face,
    ].join(' ');
    final columns = [
      for (final column in _columns)
        column.map((card) => card.face).join(' '),
    ].join('\n');
    return 'cells $cells   home $homes\n$columns';
  }
}
