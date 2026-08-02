# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test verify analyze shots book apk ios clean

# Everything that has to be green. What the pre-push hook runs, because there
# is no CI here: nothing leaves this machine unless it analyzes and the tests
# pass.
check: analyze test

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
