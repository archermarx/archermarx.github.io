STRING1 = "Last updated on "
STRING2 = "Created using [TSPW]\(https://github.com/eakbas/TSPW\) and [pandoc]\(http://pandoc.org/\)."
SHELL = /bin/bash

ASSETDIR = "assets"
TARGETDIR = ".."

SOURCES = $(wildcard *.md) $(wildcard content/*.md)
HTMLs = $(patsubst %.md,$(TARGETDIR)/%.html,$(SOURCES))
TEMPFILE = $(TARGETDIR)/tmpfile

all: mkdir $(HTMLs)

mkdir:
	@ mkdir -p $(TARGETDIR)

$(TARGETDIR)/%.html: %.md
	@ echo $@
	@ dir=$(@D) ; \
		mkdir -p $$dir; \
		depth=$$(grep -o '/' <<<"$$dir" | grep -c .); \
		reldir=$$(for i in `seq $$depth`; do echo "../";done); \
	  cat $< > $(TEMPFILE); \
	 	echo "\n\\ \n\n\\ \n\n***\n\n<span class="footer">*$(STRING1) `stat -c %Y Makefile  | date +'%b %d, %Y'`. $(STRING2)*</span>" >> $(TEMPFILE); \
	 	pandoc --from=markdown --mathml --citeproc --lua-filter='../assets/lua/bold-name.lua' -t html5 -s -c $$reldir$(ASSETDIR)/css/style.css $(TEMPFILE) -o $@
	@ rm -f $(TEMPFILE)

clean: 
	@ rm -rf ../*.html ../content ../tmpfile

remake: clean all
