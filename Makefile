DOCNAME = I08

tex = $(filter-out $(wildcard *acronyms.tex) , $(wildcard *.tex))

GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif

export TEXMFHOME = lsst-texmf/texmf

#$(DOCNAME).pdf: $(tex) meta.tex O3-002.bib authors.tex acronyms.tex
#	latexmk -bibtex -xelatex -f $(DOCNAME)

I08.pdf: $(tex) $(DOCNAME).bib 
	latex $(DOCNAME)
	bibtex $(DOCNAME)
	latex $(DOCNAME)
	latex $(DOCNAME)
	dvipdfm $(DOCNAME)
	dvipdf $(DOCNAME)

# Acronym tool allows for selection of acronyms based on tags - you may want more than DM
acronyms.tex: $(tex) myacronyms.txt
	$(TEXMFHOME)/../bin/generateAcronyms.py -t "DM" $(tex)

# Remove the USA from the author list since that can be assumed
authors.tex:  authors.yaml
	python3 $(TEXMFHOME)/../bin/db2authors.py --mode adass > authors.tex
	perl -pi -e 's|, USA||' authors.tex

.PHONY: clean
clean:
	latexmk -c
	rm -f $(DOCNAME).bbl
	rm -f $(DOCNAME).out
	rm -f $(DOCNAME).dvi
	rm -f $(DOCNAME).xdv
	rm -f meta.tex

.FORCE:

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	echo '% GENERATED FILE -- edit this in the Makefile' >>$@
	/bin/echo '\newcommand{\lsstDocType}{$(DOCTYPE)}' >>$@
	/bin/echo '\newcommand{\lsstDocNum}{$(DOCNUMBER)}' >>$@
	/bin/echo '\newcommand{\vcsRevision}{$(GITVERSION)$(GITDIRTY)}' >>$@
	/bin/echo '\newcommand{\vcsDate}{$(GITDATE)}' >>$@
