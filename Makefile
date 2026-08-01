# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: all deps analyze test apk shots clean

# What CI's first job runs, and the pair worth running before a commit.
all: analyze test

deps:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

apk:
	flutter build apk --debug

shots:
	@echo 'Rendering the screens at phone sizes into build/showcase.'
	flutter test --tags showcase --update-goldens test/showcase_test.dart
	@echo
	@echo 'These are the real widget tree at real phone dimensions, drawn by'
	@echo 'the same engine the app uses, which is the fastest way to see what a'
	@echo 'change did to the look of the game.'
	@echo
	@echo 'Pictures of the game running ON a phone come from CI: this machine is'
	@echo 'aarch64, where no Android emulator is published, and iOS needs a Mac.'
	@echo 'The shots-android and shots-ios jobs boot a real emulator and a real'
	@echo 'simulator and upload what they photograph.'

clean:
	flutter clean
