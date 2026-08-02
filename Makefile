# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots dryrun apk ios clean

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
# logo and the app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# Plays the whole game three ways with nobody at the controls and reports how
# far each got. This is what the waves and the tower numbers were tuned
# against; run it before believing any change to either.
dryrun:
	dart run tool/dryrun.dart

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
