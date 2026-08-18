import 'package:shared_preferences/shared_preferences.dart';

/// The fewest swaps each ask has ever been landed in, kept on the phone.
class Best {
  static SharedPreferences? _kept;

  static Future<void> ready() async {
    _kept ??= await SharedPreferences.getInstance();
  }

  static String _key(String name) => 'yokemere.fewest.$name';

  static int? fewest(String name) => _kept?.getInt(_key(name));

  /// Keeps [swaps] if it beats the standing record. True when it did.
  static Future<bool> landed(String name, int swaps) async {
    await ready();
    final standing = fewest(name);
    if (standing != null && standing <= swaps) return false;
    await _kept!.setInt(_key(name), swaps);
    return true;
  }
}
