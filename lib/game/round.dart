import 'dart:math';

import 'board.dart';
import 'lexicon.dart';
import 'maker.dart';

/// One go at one board.
///
/// A round is a pure function of its seed, which is what lets a player play
/// the same board again, tell someone else which one it was, and lets a
/// screenshot taken on a build server show the board a phone would show.
///
/// Everything the end of the round has to say is worked out here, when the
/// round is made: the words the board holds and what they are worth. A
/// countdown is no time to be walking the board, and the walk is what makes
/// the missed list possible at all.
class Round {
  Round._({
    required this.seed,
    required this.board,
    required this.words,
    required this.length,
  });

  factory Round.of(
    int seed, {
    required Lexicon lexicon,
    int size = 5,
    Duration length = standardLength,
  }) {
    final board =
        Maker(lexicon: lexicon, random: Random(seed)).make(size: size);
    return Round._(
      seed: seed,
      board: board,
      words: board.everyWord,
      length: length,
    );
  }

  /// Long enough to find a decent handful on a board worth playing, short
  /// enough that a go fits in a queue.
  static const standardLength = Duration(seconds: 120);

  static final Random _seeds = Random();

  /// A number for a new round, kept to five digits so a player who wants this
  /// board again has something they can actually carry.
  static int freshSeed() => _seeds.nextInt(99999) + 1;

  final int seed;
  final Board board;

  /// Every word on this board, found or not.
  final Set<String> words;

  final Duration length;

  /// The same round with the board moved on, which is what a found word does
  /// to it. The word list is carried over rather than walked again.
  Round on(Board board) => Round._(
        seed: seed,
        board: board,
        words: words,
        length: length,
      );

  /// The words found, oldest first, which is the order the board kept them in.
  List<String> get found => board.found.toList();

  int get score => board.score;

  /// What the whole board was worth, so a score has something to be measured
  /// against.
  int get possible => words.fold(0, (sum, word) => sum + Board.scoreOf(word));

  /// What was left, longest first: the long ones are the ones a player wants
  /// to see they walked past.
  List<String> get missed => ranked(words.difference(board.found));

  /// Longest first, and alphabetical within a length, so a list of words is
  /// ordered by what it was worth rather than by nothing at all.
  static List<String> ranked(Iterable<String> words) => words.toList()
    ..sort((a, b) =>
        a.length == b.length ? a.compareTo(b) : b.length.compareTo(a.length));
}
