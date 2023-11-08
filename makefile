# Inline code styling:
# https://learnbyexample.github.io/customizing-pandoc/
#
# Citation CSL files:
# https://github.com/citation-style-language/styles
#
# Pagebreak Lua filter:
# https://github.com/pandoc-ext/pagebreak

# Settings for templates should be done
# in YAML frontmatter in markdown files

input_file  ?= draft.md
output_name ?= output
ref_bib     ?= references.bib
csl_file    ?= pandoc_tools/ieee.csl
pdf_reader  ?= zathura

all: pdf

.ONESHELL:
.SILENT:
pdf:
	# Generate flags to trigger installed filters
	# Note that diagram-generating filters must be used before pandoc-crossref
	filter_flags=""
	filters=("mermaid-filter" "pandoc-plot" "pandoc-crossref")
	for filter in "$${filters[@]}"; do
	    if which "$$filter" >/dev/null; then
	        filter_flags+=" -F $$filter"
	    fi
	done
	
	pandoc \
	--pdf-engine=xelatex \
	--highlight-style pandoc_tools/pygments.theme \
	--include-in-header pandoc_tools/inline_code.tex \
	$$filter_flags \
	--citeproc \
	--bibliography=$(ref_bib) \
	--csl=$(csl_file) \
	-o $(output_name).pdf \
	$(input_file)

.PHONY:
p: pdf

# For reference
.ONESHELL:
.SILENT:
docx:
	pandoc \
	-L pandoc_tools/pagebreak.lua \
	-o $(output_name).docx \
	$(input_file)

.PHONY:
d: docx

# Use xdg-open to open files by default
pdf_reader ?= xdg-open

.ONESHELL:
.SILENT:
.PHONY:
open:
	if [ -f $(output_name).pdf ]; then $(pdf_reader) $(output_name).pdf &>/dev/null & disown; fi

.PHONY:
o: open

.ONESHELL:
.SILENT:
.PHONY:
clean:
	rm $(output_name).pdf $(output_name).docx -f
	rm plots -rf
	rm mermaid-filter.err -f

.PHONY:
c: clean
