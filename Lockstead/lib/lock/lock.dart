import 'dart:typed_data';

/// The shape of a lock: how many pegs, and how many colours to choose from.
///
/// A code is kept as a single number rather than a list of pegs. There are a
/// few thousand of them and a solver looks at every one against every other,
/// so the difference between a number and a list is the difference between an
/// answer and a wait.
class Lock {
  const Lock({required this.pegs, required this.colours});

  final int pegs;
  final int colours;

  /// How many codes there are.
  int get codes {
    var all = 1;
    for (var i = 0; i < pegs; i++) {
      all *= colours;
    }
    return all;
  }

  /// The colours of a code, left to right.
  List<int> pegsOf(int code) {
    final out = List.filled(pegs, 0);
    var left = code;
    for (var peg = pegs - 1; peg >= 0; peg--) {
      out[peg] = left % colours;
      left ~/= colours;
    }
    return out;
  }

  /// The code a list of colours makes.
  int codeOf(List<int> pegs) =>
      pegs.fold(0, (code, colour) => code * colours + colour);

  /// How a guess is marked against a code.
  ///
  /// Blacks are pegs of the right colour in the right place. Whites are
  /// colours that are in the code somewhere else — counted by how many of each
  /// colour are left over on both sides once the blacks are taken out, which
  /// is the only way to get repeated colours right. Marking a guess by walking
  /// it peg by peg and crossing off matches is where every version of this
  /// game gets it wrong.
  Mark markOf(int code, int guess) {
    final want = pegsOf(code);
    final tried = pegsOf(guess);

    var blacks = 0;
    final leftInCode = Uint8List(colours);
    final leftInGuess = Uint8List(colours);
    for (var peg = 0; peg < pegs; peg++) {
      if (want[peg] == tried[peg]) {
        blacks++;
      } else {
        leftInCode[want[peg]]++;
        leftInGuess[tried[peg]]++;
      }
    }

    var whites = 0;
    for (var colour = 0; colour < colours; colour++) {
      whites += leftInCode[colour] < leftInGuess[colour]
          ? leftInCode[colour]
          : leftInGuess[colour];
    }
    return Mark(blacks, whites);
  }

  /// Every mark this lock can give, in a sensible order.
  ///
  /// Not every pair of numbers is possible: nothing can be marked as all but
  /// one peg right with one in the wrong place, because there is nowhere for
  /// the odd one to go.
  List<Mark> get everyMark => [
        for (var blacks = 0; blacks <= pegs; blacks++)
          for (var whites = 0; whites <= pegs - blacks; whites++)
            if (!(blacks == pegs - 1 && whites == 1)) Mark(blacks, whites),
      ];

  /// How many different marks there could be, which is how wide a partition
  /// can get.
  int get marks => (pegs + 1) * (pegs + 2) ~/ 2;
}

/// What a guess was worth: pegs right, and colours right in the wrong place.
class Mark {
  const Mark(this.blacks, this.whites);

  final int blacks;
  final int whites;

  bool isAllRight(Lock lock) => blacks == lock.pegs;

  /// The mark as one small number, so a partition can be an array rather than
  /// a map.
  int asOne(Lock lock) => blacks * (lock.pegs + 1) + whites;

  @override
  bool operator ==(Object other) =>
      other is Mark && other.blacks == blacks && other.whites == whites;

  @override
  int get hashCode => Object.hash(blacks, whites);

  @override
  String toString() => '$blacks black, $whites white';
}
