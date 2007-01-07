# Dear emacs, this is -*- makefile -*-
# André Rabello <Andre.dos.Anjos@cern.ch>

# Este makefile, constrói os alvos do latex para este diretório
# no diretório atual. O arquivo principal deve se chamar main.tex
# por default ou você deverá trocar o valor da variável TEXFILE
# abaixo para o nome correto. A seção PROGRAMAS não deve ser mexida
# a não ser que a localização dos programas que você use não seja
# a indicada. O restante não deve ser mudado, a não ser que você 
# saiba o que está fazendo.

# NOMES
TEXFILE=main.tex
PACKNAME=$(shell basename `pwd`)
COLORPAGES=44 58 212 245 249 276
ORIGINALPAGES=

# REGRAS
PDFFILE=$(TEXFILE:%.tex=%.pdf)

all: $(PDFFILE)

# Esta regra implícita define como fazer um .pdf de um .tex
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


