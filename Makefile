export PATH := ./node_modules/.bin/:$(PATH)

FWAIT := inotifywait -qr -e close_write

POSTCSS := postcss
GZIP    := gzip --rsyncable -f -k -n -9
BROTLI  := brotli -f -k -n

CSS_SRC    := $(sort $(wildcard src/*.css))

CSS_ASSETS := $(addprefix dist/,$(notdir $(CSS_SRC)))

GZIP_ASSETS := $(addsuffix .gz,$(CSS_ASSETS))

BROTLI_ASSETS := $(addsuffix .br,$(CSS_ASSETS))

help:
	@echo "Targets:"
	@echo
	@echo "  dist   Create/update dist/*.css and map files"
	@echo "  watch  Waits for changes in src/ and makes 'dist' automatically"
	@echo "  build  Like 'dist', plus gzip and Brotli files"
	@echo "  clean  Empty dist/"
	@echo "  to-github  Rsync to ../github-paragon.css/"
	@echo

dist:	$(CSS_ASSETS)

build:	$(CSS_ASSETS) $(GZIP_ASSETS) $(BROTLI_ASSETS)

clean:
	rm -fv dist/*

watch:	dist
	@echo "Watching src/ for changes..."
	+@while true; do $(FWAIT) $(CSS_SRC) ; nice make --no-print-directory dist; echo "Up to date."; done

# Pessimistic by design: rebuilds all assets whenever any source changes.
dist/%.css:	src/%.css $(CSS_SRC)
	$(POSTCSS) $< -o $@

%.gz:	%
	$(GZIP) $<

%.br:	%
	$(BROTLI) $<

to-github:
	rsync -xahiv --delete --exclude '.git' --exclude 'node_modules' --exclude '*.gz' --exclude '*.br' ./ ../github-paragon-css/

# Don't let make search for files with coinciding names.
.PHONY: help dist build clean to-github watch

.SILENT:	help
