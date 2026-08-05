# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

# Scratch goes on the container's own disk, not on the shared one this
# repository lives on. Building fourteen Flutter projects writes a few
# gigabytes of files that are gitignored anyway, and the disk under /work is
# shared with whatever else is running on this machine — when it fills, every
# command in the container stops, not just this one.
export TMPDIR := /var/tmp

# Where build output goes instead of into the games. See `make scratch`.
SCRATCH := /var/cache/thumbworks

# Every game in the collection, oldest first. Adding one means adding it here
# and nowhere else.
GAMES := Wirewend Slingwell Latchword Tallyloom Thornguard Emberlane \
         Fanwright Vaultline Chimefall Chalkway Cinderplot Haulyard \
         Hazardwell Lockstead Rungwick Cairnfall Rookvale

.PHONY: check test analyze deps shots apk clean list one scratch

# Everything that has to be green, in every game. What the pre-push hook runs,
# because there is no CI behind it: nothing leaves this machine unless all of
# it passes.
#
# It stops at the first game that fails rather than carrying on, because a
# wall of output from twelve games that were fine is not how anybody finds the
# one that was not.
check:
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game check || exit 1; \
	done
	@printf '\nall %s games green\n' "$(words $(GAMES))"

# Points every game's build/ at the container's own disk.
#
# Needs running once on a fresh container, and it is safe to run again: build
# output is regenerable by definition, which is exactly what belongs on a disk
# that does not survive a rebuild.
scratch:
	@for game in $(GAMES); do \
	  if [ ! -L $$game/build ]; then \
	    rm -rf $$game/build; \
	    mkdir -p $(SCRATCH)/$$game; \
	    ln -s $(SCRATCH)/$$game $$game/build; \
	    echo "$$game/build -> $(SCRATCH)/$$game"; \
	  fi; \
	done

# One game, for when only one of them has changed:  make one GAME=Chalkway
one:
	@test -n "$(GAME)" || { echo "which one? make one GAME=Chalkway"; exit 1; }
	@$(MAKE) --no-print-directory -C $(GAME) check

test:
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game test || exit 1; \
	done

analyze:
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game analyze || exit 1; \
	done

deps:
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game deps || exit 1; \
	done

# Redraws every game's screens and its logo. Slower than it sounds worth, and
# the only way to see at a glance what a change to a shared idea did to all of
# them.
shots:
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game shots || exit 1; \
	done

clean:
	@for game in $(GAMES); do $(MAKE) --no-print-directory -C $$game clean; done

list:
	@for game in $(GAMES); do \
	  printf '%-12s %s\n' "$$game" "$$(sed -n '5p' $$game/README.md)"; \
	done
