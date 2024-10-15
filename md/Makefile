TARGETDIR=..

md-files := \
	$(wildcard *.md) \
	$(wildcard content/*.md) \
	$(wildcard p/*.md) \
	$(wildcard extras/*.md)

html-files := $(md-files:%.md=$(TARGETDIR)/%.html)

.PHONY: all clean debug
all: $(html-files)

$(TARGETDIR)/%.html: %.md
	@ ./make.py $@ $< $(@D)

clean: 
	@ rm -rf ../*.html ../content ../p ../extras

debug:
	@ echo $(html-files)
	@ echo $(md-files)
