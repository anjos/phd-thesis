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
COLORPAGES=44 46 60 144 146 147 148 184 194 214 234 244 247 251 278 281
ORIGINALPAGES=47 51 56 63 65 66 68 70 71 73 75 88 92 95 100 102 104 105 108 110 112 118 121 128 129 167 169 170 172 174 178 181 182 183 185 189 190 191 192 200 201 205 208 209 210 211 216 217 219 221 227 228 231 232 233 236 237 241 266 272 274 275 277 279 306 315 316 317 320 322 323
COPYPAGES=2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 45 48 49 50 52 53 54 55 57 58 59 61 62 64 67 69 72 74 76 77 78 79 80 81 82 83 84 85 86 87 89 90 91 93 94 96 97 98 99 101 103 106 107 109 111 113 114 115 116 117 119 120 122 123 124 125 126 127 130 131 132 133 134 135 136 137 138 139 140 141 142 143 145 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 168 171 173 175 176 177 179 180 186 187 188 193 195 196 197 198 199 202 203 204 206 207 212 213 215 218 220 222 223 224 225 226 229 230 235 238 239 240 242 243 245 246 248 249 250 252 253 254 255 256 257 258 259 260 261 262 263 264 265 267 268 269 270 271 273 276 280 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 307 308 309 310 311 312 313 314 318 319 321 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339

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

colorido.pdf: $(PDFFILE)
	pdftk $? cat $(COLORPAGES) output $@

original.pdf: $(PDFFILE)
	pdftk $? cat $(ORIGINALPAGES) output $@

podecopiar.pdf: $(PDFFILE)
	pdftk $? cat $(COPYPAGES) output $@

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


