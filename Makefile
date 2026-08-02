.PHONY: deps test verify analyze shots book apk ios clean

deps:
	flutter pub get

test:
	flutter test

# Everything the normal run leaves out. The line solver is checked
# exhaustively against a brute force version, and the width it goes up to
# triples in cost with every square, so the normal run stops at eight and this
# goes to eleven.
verify:
	TALLYLOOM_LINE_WIDTH=11 flutter test

analyze:
	flutter analyze

# Renders the game at real phone sizes into build/showcase, and redraws the
# logo and the app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# Prints what the book deals: size, how many solver passes each puzzle needs,
# and how many pictures were thrown away to find it.
book:
	dart run tool/book_report.dart 120

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
