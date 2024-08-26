SVG = paper/paper.svg
PDF = paper/paper.pdf
LINEGRID = bin/linegrid
TWOUP = bin/2up
PDF2UP = $(patsubst %.pdf,%.2up.pdf,$(PDF))
INKSCAPE_OPTIONS =
PDF2PS_OPTIONS =

.PHONY: default
default: engpaper.pdf gridpaper.pdf

engpaper.svg: Makefile bin/engpaper
	bin/engpaper > "$@.tmp"
	mv "$@.tmp" "$@"

gridpaper.svg: Makefile bin/linegrid16
	bin/linegrid16 --color=green > "$@.tmp"
	mv "$@.tmp" "$@"

%.pdf: %.svg bin/svg2pdf
	bin/svg2pdf "$<"

clean:
	rm $(ALLPS) $(ALLPDF) $(SVG) 2>/dev/null || true
