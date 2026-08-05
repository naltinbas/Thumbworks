# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots fewest puzzles apk ios clean

# Everything that has to be green. What the pre-push hook runs, because there
# is no CI here: nothing leaves this machine unless it analyzes and the tests
# pass.
check: analyze test

deps:
	flutter pub get

test:
	flutter test

analyze:
	flutter analyze

# Renders the game at real phone sizes into build/showcase, and redraws the
# logo and every app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# Works out the fewest comparators for two lines up to however many are
# asked for. Seven takes about a minute and a half.
#   make fewest ARGS=7
fewest:
	dart run tool/fewest.dart $(ARGS)

# Walks every shipped puzzle: whether what it starts with still finishes in
# the number it promises.
puzzles:
	dart run tool/check_siftings.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
