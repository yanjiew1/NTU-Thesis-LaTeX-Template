# -----------------------------------------------------------------------------
# Makefile for NTU Thesis
# -----------------------------------------------------------------------------

# Use 'latexmk' as the primary build engine.
# Settings are primarily controlled via '.latexmkrc'

MAIN = main
PDF = $(MAIN).pdf
FINAL_PDF = final.pdf
LATEXMK = latexmk
QPDF = qpdf
# -f: continue on errors
# -use-make: allow latexmk to use this Makefile for missing files
# -interaction=nonstopmode: don't stop on errors
FLAGS = -f -use-make -interaction=nonstopmode
PDF_OWNER_PASSWORD ?= ntu-thesis-owner

.PHONY: all silent watch clean distclean help FORCE

# Default target: build the protected final PDF
all: $(FINAL_PDF)

# Always invoke latexmk and let it decide whether rebuilding is necessary.
FORCE:

# Build the PDF using latexmk
$(PDF): FORCE
	$(LATEXMK) $(FLAGS) $(MAIN).tex

# Build the final PDF with permissions restricted to printing and accessibility.
$(FINAL_PDF): $(PDF)
	@command -v $(QPDF) >/dev/null 2>&1 || { \
		echo "Error: qpdf is required to build $(FINAL_PDF)."; \
		echo "Install it, then run: make $(FINAL_PDF)"; \
		exit 1; \
	}
	$(QPDF) --encrypt "" "$(PDF_OWNER_PASSWORD)" 256 \
		--print=full \
		--modify=none \
		--extract=n \
		--annotate=n \
		--form=n \
		--assemble=n \
		--accessibility=y \
		-- "$<" "$@"

# Build silently (less output)
silent:
	$(LATEXMK) $(FLAGS) -silent $(MAIN).tex

# Continuous preview mode: rebuilds when files change
watch:
	$(LATEXMK) $(FLAGS) -pvc $(MAIN).tex

# Remove all generated files, including the PDF
clean:
	$(LATEXMK) -C
	@rm -f $(MAIN).bbl $(MAIN).blg $(FINAL_PDF)

# Display help information
help:
	@echo "Available targets:"
	@echo "  all       - Build protected final PDF (default)"
	@echo "  final.pdf - Build protected final PDF"
	@echo "  silent    - Build silently"
	@echo "  watch     - Continuous build mode (auto-refresh on changes)"
	@echo "  clean     - Remove all build files"
	@echo "  help      - Show this help message"
