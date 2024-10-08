STRING1 = "Last updated on "
STRING2 = "Created using [TSPW]\(https://github.com/eakbas/TSPW\) and [pandoc]\(http://pandoc.org/\)."
SHELL = /bin/bash

ASSETDIR = "assets"
TARGETDIR = ".."

SOURCES = \
	$(wildcard *.md) \
	$(wildcard content/*.md) \
	$(wildcard p/*.md) \
	$(wildcard extras/*.md)

HTMLs = $(patsubst %.md,$(TARGETDIR)/%.html,$(SOURCES))
TEMPFILE = $(TARGETDIR)/tmpfile

all: mkdir $(HTMLs)

mkdir:
	@ mkdir -p $(TARGETDIR)

$(TARGETDIR)/%.html: %.md
	@ ./make.py $@ $< $(@D)

clean: 
	@ rm -rf ../*.html ../content ../p ../extras ../tmpfile

remake: clean all
