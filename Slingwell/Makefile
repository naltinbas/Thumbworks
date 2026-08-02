# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: all check deps analyze test apk shots clean

# Everything that has to be green. What the pre-push hook runs, because there
# is no CI here: nothing leaves this machine unless it analyzes and the tests
# pass.
check: analyze test

all: check

deps:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

apk:
	flutter build apk --debug

shots:
	@echo 'Rendering the game at phone sizes into build/showcase.'
	flutter test test/showcase_test.dart
	@ls -1 build/showcase
	@echo
	@echo 'These are the real widget tree at real phone dimensions, drawn by'
	@echo 'the same engine the app uses, at moments the test plays its way to:'
	@echo 'a swing, a release, a climb, a run thrown away, the title, a run on'
	@echo 'the glass with the score on it, and the card that ends one.'
	@echo
	@echo 'Pictures of the game running ON a phone come from CI: this machine'
	@echo 'is aarch64, where no Android emulator is published, and iOS needs a'
	@echo 'Mac. The shots-android and shots-ios jobs boot a real emulator and a'
	@echo 'real simulator, play a run to twelve wells and upload what they'
	@echo 'photograph.'

clean:
	flutter clean
