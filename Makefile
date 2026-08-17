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
         Hazardwell Lockstead Rungwick Cairnfall Rookvale Wickfell \
         Skeinmoor Packwold Hollowmarch Warrenshaw Reelbury Weirbank \
         Winnowmere Carterfen Beaconholt Rimeworth Marchcombe Quayfleet \
         Churnwick Handfast Pyxholm Trestlewick Trodstow Chasegarth \
         Groatsworth Linacre Shardlow Staddlestone Lampwath \
         Treblesway Foldbury Staplemere Pinderwell Shroveham \
         Smithwaite Dipthorne Rindhope Colthorpe Tallowfield \
         Pennygill Spanham Lockhithe Filberthow Ellmarsh \
         Withyshaw Millgreave Frankmoor Turnstead Posygarth \
         Fairhold Tilthway Wickfield Shuntley Bannford \
         Bridgeholm Riddlecombe Spindlewood Ringmarsh Shadewell \
         Pailsworth Charmstead Hirebeck Skittlemere Notchfield \
         Boardleigh Ferrydale Pegbourne Tanglemere Mottlemoor Mousewold \
         Quirebeck Hurdlecote Marrowden Leystone Peckhollow \
         Knuckleby Farthingford Tussockmere Beadlow \
         Braidfell Copestone Wardhall Scoreham Gapstile Borrowfen Chainhurst Sashmoor Wickthorn Stackholt Brackenside Tetherdown Stitchfen Crookmarsh Wirecombe Pigeonwick Greetley Shelfham Pursewell Fanleigh Addlemoor Marklow Hamperfen Beamsworth Noughtsmill Matchcote Coursewell Acreford Peckthorne Wantley Squarholt Thrissleton Daisyholme Inkfen Rackenford Slicebury Watchmere Sortlow Dealstone Starholme Clinkfield Oddrow Foursworth Tablesham Studwell Evenholt Frogmere Setwick Sweetleigh Shiftwell Kerbwell Loafham Trayford Riffleford Thirdwell Rowsworth Steedwick Foldwick Stillmere Midford Wheelford Evenmoor Slateford Patchmere Knotford Throwsden Stilemere Stookwell Mitrewick Ledgeworth Milesworth Capwick Rowsden Cubewick Weighwick Cloakwell Fusewick Trickmere Cupwell Suppermere Whistlecote Copperwick Farrierstead Slantbury Brickholme Crownwick Combwell Cutlassby Cutmere Squarebrook Halvingham Muxholme Turnwick Watchcombe Weaveholme \
  Fridayford Loadwick Leechmere Wedgeworth Framley Crustleigh Laneford Candleford Cornerstow Goatsbridge Baizewell Fevershaw Bakerley Mootbury Almsford Arrowmere Beadmere \
         Beamsley Benchwood

.PHONY: check test analyze deps shots apk clean list one scratch images

# Everything that has to be green, in every game. What the pre-push hook runs,
# because there is no CI behind it: nothing leaves this machine unless all of
# it passes.
#
# It stops at the first game that fails rather than carrying on, because a
# wall of output from twelve games that were fine is not how anybody finds the
# one that was not.
check: images
	@for game in $(GAMES); do \
	  printf '\n=== %s ===\n' "$$game"; \
	  $(MAKE) --no-print-directory -C $$game check || exit 1; \
	done
	@printf '\nall %s games green\n' "$(words $(GAMES))"

# Every picture any README points at, checked for being there and committed.
# A broken image never shows up locally — the file is sitting in the working
# copy and the page on GitHub has a hole in it — so it is part of `check`.
images:
	@dart tool/images.dart

# Points every game's build/ at the container's own disk.
#
# Needs running once on a fresh container, and it is safe to run again: build
# output is regenerable by definition, which is exactly what belongs on a disk
# that does not survive a rebuild.
# The directory is made every time, not only when the link is. The link lives
# in this repository and survives a rebuilt container; what it points at lives
# on the container's own disk and does not. A link left pointing at nothing
# fails every build with a path error that says nothing about why.
scratch:
	@for game in $(GAMES); do \
	  mkdir -p $(SCRATCH)/$$game; \
	  if [ ! -L $$game/build ]; then \
	    rm -rf $$game/build; \
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
