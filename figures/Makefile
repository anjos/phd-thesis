# Converte entre formatos gr�ficos
# Andr� DOS ANJOS <Andre.dos.Anjos@cern.ch>

GIFFILE=

%.png: %.gif
	convert $< $@

%.jpg: %.gif
	convert $< $@

%.pdf: %.eps
	epstopdf $< --output=$@

topng: $(GIFFILE:%.gif=%.png)

.PHONY: clean

clean:
	rm -f *~ *.bak
