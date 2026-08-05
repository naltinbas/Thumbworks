/// The pieces, and how each one moves.
enum Piece { pawn, knight, bishop, rook, queen, king }

/// What each one is called and what it does.
extension PieceWords on Piece {
  String get name => switch (this) {
        Piece.pawn => 'pawn',
        Piece.knight => 'knight',
        Piece.bishop => 'bishop',
        Piece.rook => 'rook',
        Piece.queen => 'queen',
        Piece.king => 'king',
      };

  /// The letter it is written with, which is also how a board is written out.
  String get letter => switch (this) {
        Piece.pawn => 'P',
        Piece.knight => 'N',
        Piece.bishop => 'B',
        Piece.rook => 'R',
        Piece.queen => 'Q',
        Piece.king => 'K',
      };

  String get says => switch (this) {
        Piece.pawn => 'One square diagonally forwards, and up the board is '
            'forwards for everything here.',
        Piece.knight => 'Two squares one way and one the other.',
        Piece.bishop => 'Any distance diagonally, over nothing.',
        Piece.rook => 'Any distance straight, over nothing.',
        Piece.queen => 'Any distance straight or diagonally, over nothing.',
        Piece.king => 'One square in any direction.',
      };

  static Piece? ofLetter(String letter) {
    for (final piece in Piece.values) {
      if (piece.letter == letter) return piece;
    }
    return null;
  }
}
