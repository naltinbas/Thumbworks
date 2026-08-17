/// Eight signal lamps down the valley, each lit or dark, read from the
/// near end. The message is worth the sum of the places of its lit
/// lamps: lamp 1 is worth 1, lamp 2 is worth 2, and on to lamp 8.
///
/// A message is in the code when that sum comes to nothing over nine,
/// which is the lamps plus one. Then any single lamp can go out and the
/// reader still gets the message back, without being told which lamp
/// went. Varshamov and Tenengolts published the code in 1965 and
/// Levenshtein showed that year that it corrects a lost lamp.
class Rules {
  static const lamps = 8;

  /// The sums are taken over the lamps plus one.
  static int get over => lamps + 1;

  /// The message a go opens on: the last three lamps lit.
  static const opening = [0, 0, 0, 0, 0, 1, 1, 1];

  static bool valid(List<int> message) =>
      message.length == lamps &&
      message.every((lamp) => lamp == 0 || lamp == 1);

  /// The sum of the places of the lit lamps.
  static int weight(List<int> message) {
    var out = 0;
    for (var i = 0; i < message.length; i++) {
      out += (i + 1) * message[i];
    }
    return out;
  }

  /// What the sum comes to over nine.
  static int over9(List<int> message) => weight(message) % over;

  /// Whether the message is in the code.
  static bool inCode(List<int> message) => over9(message) == 0;

  static int lit(List<int> message) {
    var out = 0;
    for (final lamp in message) {
      out += lamp;
    }
    return out;
  }

  /// The message as the reader sees it when lamp [gone] goes out,
  /// counting the lamps from 1.
  static List<int> lost(List<int> message, int gone) =>
      [...message.sublist(0, gone - 1), ...message.sublist(gone)];

  /// The first voice: the reader's arithmetic. It is told nothing about
  /// which lamp went out, only the seven it can see, and it puts one
  /// back by counting.
  static List<int>? read(List<int> seen) {
    final w = lit(seen);
    var sum = 0;
    for (var i = 0; i < seen.length; i++) {
      sum += (i + 1) * seen[i];
    }
    final short = (over - sum % over) % over;
    if (short <= w) {
      // A dark lamp went out, with exactly that many lit lamps beyond
      // it.
      var beyond = 0;
      for (var at = seen.length; at >= 0; at--) {
        if (beyond == short) {
          return [...seen.sublist(0, at), 0, ...seen.sublist(at)];
        }
        if (at > 0 && seen[at - 1] == 1) beyond++;
      }
      return null;
    }
    // A lit lamp went out, with exactly that many dark lamps before it.
    final before = short - w - 1;
    var dark = 0;
    for (var at = 0; at <= seen.length; at++) {
      if (dark == before) {
        return [...seen.sublist(0, at), 1, ...seen.sublist(at)];
      }
      if (at < seen.length && seen[at] == 0) dark++;
    }
    return null;
  }

  /// Whether the reader gets the message back when lamp [gone] goes
  /// out.
  static bool holds(List<int> message, int gone) {
    final back = read(lost(message, gone));
    return back != null && back.join() == message.join();
  }

  /// Every message the lamps can send.
  static List<List<int>> messages() {
    final out = <List<int>>[];
    for (var mask = 0; mask < 1 << lamps; mask++) {
      out.add([for (var i = 0; i < lamps; i++) mask >> i & 1]);
    }
    return out;
  }

  static int get howManyMessages => 1 << lamps;

  /// The lamps that differ between two messages.
  static int taps(List<int> from, List<int> to) {
    var out = 0;
    for (var i = 0; i < lamps; i++) {
      if (from[i] != to[i]) out++;
    }
    return out;
  }

  static String tellMessage(List<int> message) =>
      [for (final lamp in message) lamp == 1 ? 'o' : '.'].join();
}
