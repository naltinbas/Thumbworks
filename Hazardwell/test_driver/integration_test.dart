import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// The half of a `flutter drive` run that happens on this machine rather than
/// on the phone, which is the half with a disk CI can upload from.
///
/// Every picture the screenshot test takes comes back here as bytes and is
/// written next to the build output.
Future<void> main() async {
  final shots = Directory('build/screenshots')..createSync(recursive: true);

  await integrationDriver(
    // The default writes the same images out a second time as a json array of
    // integers, which is several megabytes of nothing anybody reads.
    responseDataCallback: null,
    onScreenshot: (
      String name,
      List<int> image, [
      Map<String, Object?>? args,
    ]) async {
      File('${shots.path}/$name.png').writeAsBytesSync(image);
      // False here would fail the test, which is for drivers that compare a
      // shot against a reference. This one only keeps them.
      return true;
    },
  );
}
