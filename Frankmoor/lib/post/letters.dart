import 'letter.dart';

/// The letters that ship.
///
/// Two of them can never be paid, and both are the largest such amount
/// their stamps allow: twenty three pence against fives and sevens,
/// twenty seven against fives and eights, each the old rule's ab minus a
/// minus b. Everything above those numbers is payable forever, which is
/// the strangest part of the whole business.
class Letters {
  const Letters._();

  static final List<Letter> all = [
    Letter(
      name: 'The First Letter',
      cheap: 5,
      dear: 7,
      amount: 24,
      payable: true,
      note: 'Two of each: ten and fourteen make twenty four. Most '
          'amounts near the top are this friendly.',
    ),
    Letter(
      name: 'The Odd Parcel',
      cheap: 5,
      dear: 7,
      amount: 33,
      payable: true,
      note: 'Reaching for fives first strands you: thirty three wants '
          'four sevens and a single five, and no other way.',
    ),
    Letter(
      name: 'The Unpayable',
      cheap: 5,
      dear: 7,
      amount: 23,
      payable: false,
      note: 'Twenty three is five times seven, less five, less seven: '
          'the largest amount these stamps can never pay. Every penny '
          'above it can be paid, forever.',
    ),
    Letter(
      name: 'The Thruppenny Counter',
      cheap: 3,
      dear: 8,
      amount: 14,
      payable: true,
      note: 'With threes and eights the last unpayable amount is '
          'thirteen: one less than this very letter.',
    ),
    Letter(
      name: 'The Last Gap',
      cheap: 5,
      dear: 8,
      amount: 27,
      payable: false,
      note: 'Five eights less five less eight: twenty seven, the last '
          'gap fives and eights ever leave. The rule is the same rule '
          'every pair of stamps obeys.',
    ),
  ];

  static int get count => all.length;

  static Letter at(int number) => all[number.clamp(0, all.length - 1)];
}
