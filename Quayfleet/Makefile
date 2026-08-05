# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots days find apk ios clean

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

# Walks every shipped day: the most ships the rule gives, the most a search
# over every set of ships gives, and what the two obvious ways would have got.
days:
	dart run tool/check_days.dart

# Makes days up and keeps the ones where both obvious ways come out short:
#   make find ARGS="9 6 20 2 4"
find:
	dart run tool/find_days.dart $(ARGS)

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
