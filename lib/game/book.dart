import 'deals.dart';

/// The deals this game hands out.
///
/// Every one was proved winnable before it went in the list — see
/// tool/build_book.dart, which is what wrote deals.dart. Doing that check on
/// the phone is not on: it takes a few milliseconds for most deals and half a
/// minute for the odd one, and a player waiting to be dealt to should wait for
/// nothing at all.
///
/// The numbers are the old ones, so a deal here is the same deal anybody else
/// means by that number.
class Book {
  const Book._();

  static List<int> get numbers => kDeals;
  static int get count => kDeals.length;

  /// The deal at a place in the book, counting from zero and wrapping, so a
  /// player who works through it all is dealt the first one again rather than
  /// nothing.
  static int at(int place) => kDeals[place % kDeals.length];

  /// Where a deal sits in the book, or null if it is not one of them.
  static int? placeOf(int number) {
    final at = kDeals.indexOf(number);
    return at < 0 ? null : at;
  }

  static bool holds(int number) => kDeals.contains(number);
}
