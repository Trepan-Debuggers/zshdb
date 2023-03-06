# Minimal makefile for Sphinx documentation
# We use "remake" target comments
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = python -msphinx
SPHINXPROJ    = zshdb
SOURCEDIR     = .
BUILDDIR      = _build

# Put "help" first so that "make" without argument is like "make help".
#: Give sphinx build help
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help docs all

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%:
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

#: build HTML documentation; Set $O can be for $SPHINXOPTS
all docs: Makefile
	$(MAKE) html
