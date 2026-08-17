# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots roosts apk ios clean

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

# Runs the checker: every wood of six hollows walked, four voices apiece,
# then the ledger.
roosts:
	dart run tool/check_roosts.dart

shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
