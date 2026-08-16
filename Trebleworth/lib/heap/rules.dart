/// The arithmetic of the heaps: the triangular numbers, 0, 1, 3, 6, 10
/// and so on, and which whole numbers are three of them added, nought
/// allowed. Two voices: the sweep, every triple of triangular numbers to
/// the top tried; and the odd squares, n being three triangular numbers
/// exactly when 8n + 3 is three odd squares, since 8 times a triangular
/// number k(k+1)/2 plus 1 is (2k + 1) squared.
class Rules {
  /// How far the sweep runs.
  static const top = 500;

  /// The triangular numbers to [top].
  static List<int> get triangles => [
        for (var k = 0; k * (k + 1) ~/ 2 <= top; k++) k * (k + 1) ~/ 2,
      ];

  static bool isTriangular(int n) => n >= 0 && triangles.contains(n);

  /// The ways [n] is [count] triangular numbers added, as sorted lists,
  /// nought allowed, in order.
  static List<List<int>> heaps(int n, int count) {
    final ts = triangles.where((t) => t <= n).toList();
    final out = <List<int>>[];
    final pick = <int>[];
    void go(int from, int left, int sum) {
      if (left == 0) {
        if (sum == n) out.add(List.of(pick));
        return;
      }
      for (var i = from; i < ts.length && sum + ts[i] <= n; i++) {
        pick.add(ts[i]);
        go(i, left - 1, sum + ts[i]);
        pick.removeLast();
      }
    }

    go(0, count, 0);
    return out;
  }

  /// The ways 8n + 3 is three odd squares added, as sorted lists of the
  /// odd roots, in order: the second voice.
  static List<List<int>> oddSquares(int n) {
    final want = 8 * n + 3;
    final out = <List<int>>[];
    for (var a = 1; a * a <= want; a += 2) {
      for (var b = a; a * a + b * b <= want; b += 2) {
        final rest = want - a * a - b * b;
        if (rest < b * b) continue;
        var c = b;
        while (c * c < rest) {
          c += 2;
        }
        if (c * c == rest) out.add([a, b, c]);
      }
    }
    return out;
  }

  /// A heap told: '10 + 10 + 0'.
  static String told(List<int> heap) => heap.reversed.join(' + ');
}
