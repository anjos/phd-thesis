# Dear emacs, this is -*- makefile -*-
# Andr� Rabello <Andre.dos.Anjos@cern.ch>

# Este makefile, constr�i os alvos do latex para este diret�rio
# no diret�rio atual. O arquivo principal deve se chamar main.tex
# por default ou voc� dever� trocar o valor da vari�vel TEXFILE
# abaixo para o nome correto. A se��o PROGRAMAS n�o deve ser mexida
# a n�o ser que a localiza��o dos programas que voc� use n�o seja
# a indicada. O restante n�o deve ser mudado, a n�o ser que voc� 
# saiba o que est� fazendo.

# NOMES
TEXFILE=main.tex
PACKNAME=$(shell basename `pwd`)
COLORPAGES=44 58 212 245 249 276
ORIGINALPAGES=

# REGRAS
PDFFILE=$(TEXFILE:%.tex=%.pdf)

all: $(PDFFILE)

# Esta regra impl�cita define como fazer um .pdf de um .tex
%.pdf: %.tex
	pdflatex $(@:%.pdf=%.tex)
	bibtex $(@:%.pdf=%)
	makeindex -s $(@:%.pdf=%.ist) -t $(@:%.pdf=%.glg) -o $(@:%.pdf=%.gls) $(@:%.pdf=%.glo)
	pdflatex $(@:%.pdf=%.tex)
	pdflatex $(@:%.pdf=%.tex)

color.pdf: $(PDFFILE)
	pdftk $? cat $(COLORPAGES) output $@

$(PDFFILE): $(shell find . -name "*.tex")

.PHONY: clean pack

# for packing your document nicely
pack: deepclean
	@echo '[latex.mak] Builds a package of the current directory'
	rm -f *.pdf
	cd ..; \
		tar --use-compress-program=$(shell which bzip2) -cvf $(PACKNAME:%=%.tar.bz2) $(PACKNAME); \
		mv $(PACKNAME:%=%.tar.bz2) $(PACKNAME); cd -;
	@echo '[latex.mak] A package of the current directory is ready.'

GARBAGE = $(shell find . -name "*~")

clean:
	@rm -vf *.dvi *.ps *.pdf 
	@rm -vf $(GARBAGE)
	@rm -rvf html 

deepclean:
	@rm -vf $(GARBAGE)
	@rm -vf *.lo[gtfa] *.toc *.idx *.inc *.ilg *.ind *.bbl *.blg
	@rm -vf *.aux *.glo *.gls *.glg *.dvi *.ps *.pdf *.out *.brf *.ist
	@rm -rvf html
	@if [ -d biblio ]; then rm -fv references.bib; fi
	@if [ -d figures ]; then $(MAKE) -C figures clean; fi


