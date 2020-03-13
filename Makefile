export PATH := ./node_modules/.bin/:$(PATH)

FWAIT := inotifywait -qr -e close_write

POSTCSS := postcss
GZIP    := gzip --rsyncable -f -k -n -9
BROTLI  := brotli -f -k -n

CSS_SRC    := $(sort $(wildcard src/*.scss))

CSS_ASSETS := $(addprefix dist/,$(addsuffix .css,$(filter-out _lib,$(basename $(notdir $(CSS_SRC)))))) docs/dist.css

GZIP_ASSETS := $(addsuffix .gz,$(CSS_ASSETS))

BROTLI_ASSETS := $(addsuffix .br,$(CSS_ASSETS))

help:
	@echo "Targets:"
	@echo
	@echo "  dist   Create/update dist/ and docs/"
	@echo "  watch  Waits for changes in src/ and makes 'dist' automatically"
	@echo "  full  Like 'dist', plus gzip and Brotli files"
	@echo "  clean  Empty dist/"
	@echo "  to-github  Rsync to ../github-paragon.css/"
	@echo

dist:	$(CSS_ASSETS)

full:	$(CSS_ASSETS) $(GZIP_ASSETS) $(BROTLI_ASSETS)

clean:
	rm -fv dist/* docs/dist.*

watch:	dist
	@echo "Watching src/ for changes..."
	+@while true; do $(FWAIT) $(CSS_SRC) ; nice make --no-print-directory dist; echo "Up to date."; done

# Pessimistic by design: rebuilds all assets whenever any source changes.
dist/%.css:	src/%.scss $(CSS_SRC)
	$(POSTCSS) $< -o $@

docs/dist.css:	docs/style.css $(CSS_SRC)
	$(POSTCSS) $< -o $@

%.gz:	%
	$(GZIP) $<

%.br:	%
	$(BROTLI) $<

to-github:
	rsync -xahiv --delete --exclude '.git' --exclude 'node_modules' --exclude '*.gz' --exclude '*.br' ./ ../github-paragon-css/

# Don't let make search for files with coinciding names.
.PHONY: help dist full clean to-github watch

.SILENT:	help
