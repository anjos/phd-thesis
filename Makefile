# Dear emacs, this is -*- makefile -*-
# Andr� Rabello <Andre.dos.Anjos@cern.ch>
# $Id$

# Este makefile, constr�i os alvos do latex para este diret�rio
# no diret�rio atual. O arquivo principal deve se chamar main.tex
# por default ou voc� dever� trocar o valor da vari�vel TEXFILE
# abaixo para o nome correto. A se��o PROGRAMAS n�o deve ser mexida
# a n�o ser que a localiza��o dos programas que voc� use n�o seja
# a indicada. O restante n�o deve ser mudado, a n�o ser que voc� 
# saiba o que est� fazendo.

# ------------
# SE��O: NOMES (mude os nomes dos arquivos)
# ------------

TEXFILE=main.tex
PACKNAME=$(shell basename `pwd`)
COLORPAGES=44 58 212 245 249 276

# FIM DA SE��O NOMES

# ----------------
# SE��O: PROGRAMAS (sintonize o que voc� acha necess�rio)
# ----------------

THUMBPDFOPTS=
DVIPSOPTS=-ta4
TAROPT_PACK=--use-compress-program=$(shell which bzip2) -cvf

# FIM DA SE��O PROGRAMAS

# -------------
# SE��O: REGRAS (procure n�o alterar daqui para baixo)
# -------------

DVIFILE=$(TEXFILE:%.tex=%.dvi)
PSFILE=$(TEXFILE:%.tex=%.ps)
PDFFILE=$(TEXFILE:%.tex=%.pdf)
BIBFILES=$(shell if [ -d biblio ]; then find biblio -name "*.bib"; fi)

# Esta regra impl�cita define como fazer um .dvi de um .tex

%.dvi: %.tex
	@if [ ! -e $(@:%.dvi=%.aux) ]; then \
	 latex $(@:%.dvi=%.tex); \
	 fi
	@if [ -e references.bib ]; then \
	 bibtex $(@:%.dvi=%); \
	 latex $(@:%.dvi=%.tex); \
	fi
#	makeindex $(MAKEINDEXOPTS) $(@:%.dvi=%.idx)
	latex $(@:%.dvi=%.tex)

%.pdf: %.tex
	@if [ ! -e $(@:%.pdf=%.aux) ]; then \
	 pdflatex $(@:%.pdf=%.tex); \
	 fi
	@if [ -e references.bib ]; then \
	 bibtex $(@:%.pdf=%); \
	 pdflatex $(@:%.pdf=%.tex); \
	fi
	makeindex -s $(@:%.pdf=%.ist) -t $(@:%.pdf=%.glg) -o $(@:%.pdf=%.gls) $(@:%.pdf=%.glo)
#	thumbpdf $(THUMBPDFOPTS) $@
	pdflatex $(@:%.pdf=%.tex)

all: $(PDFFILE) #$(PSFILE)

color.pdf: $(PDFFILE)
	pdftk $? cat $(COLORPAGES) output $@

$(PDFFILE): $(shell find . -name "*.tex")

$(PSFILE): $(DVIFILE)
	dvips $(DVIPSOPTS) $(DVIFILE) -o $(PSFILE)

references.bib: $(BIBFILES)
	@if [ -d biblio ]; then \
		@echo '[latex.mak] Building you bibliographic database...';\
		$(MAKE) -C biblio all-bib DOCUMENT_ROOT=`pwd`;\
		latex $(TEXFILE);\
		$(MAKE) -C biblio simple-bib DOCUMENT_ROOT=`pwd`;\
	 fi

# HTML file creation
html: html-doc html-adjust

html-doc: $(DVIFILE)
	latex2html main.tex

html-adjust:
	@if [ ! -d html ]; then \
		$(MAKE) html; \
	 fi
	@echo '[latex.mak] Changing HTML defaults.'
	@for htmlfile in `ls --color=no html/*.html`; do\
		gawk -f html-adjust.awk	$$htmlfile > $$htmlfile.tmp;\
		mv -f $$htmlfile.tmp $$htmlfile;\
	 done

.PHONY: clean pack web-pack-init web-pack web-clean

# for packing your document nicely
pack: clean
	@echo '[latex.mak] Builds a package of the current directory'
	rm -f *.ps *.pdf
	cd ..; \
		tar $(TAROPT_PACK) $(PACKNAME:%=%.tar.bz2) $(PACKNAME); \
		mv $(PACKNAME:%=%.tar.bz2) $(PACKNAME); cd $(PACKNAME);
	@echo '[latex.mak] A package of the current directory is ready.'

web-pack-init: web-clean ps html
	@mkdir web;
	@mv html web;
	@mv $(PSFILE) $(PACKNAME:%=web/%.ps);
	@gzip $(PACKNAME:%=web/%.ps);

web-pack: web-pack-init pack
	@mv $(PACKNAME:%=%.tar.bz2) web;
	@echo '[latex.mak] Your web pack is ready.'

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

web-clean: 
	@rm -rvf web

# FIM DA SE��O REGRAS

