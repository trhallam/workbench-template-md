## ========================================
## Commands for both workshop and lesson websites.

# Settings
MAKEFILES=Makefile $(wildcard *.mk)
R=/usr/bin/R -e
DST=site

# Find Docker
DOCKER := $(shell which docker 2>/dev/null)

# Default target
.DEFAULT_GOAL := commands

## I. Commands for both workshop and lesson websites
## =================================================

.PHONY: site docker-serve repo-check clean clean-rmd

## * serve            : render website and run a local server
serve : lesson-md index.md
	${R} -e 'sandpaper::serve()'

## * site             : build website but do not run a server
site : lesson-md index.md
	${R} 'sandpaper::build_lesson()'

## * docker-serve     : use Docker to serve the site
docker-serve :
ifeq (, $(DOCKER))
	$(error Your system does not appear to have Docker installed)
else
	@$(DOCKER) build --pull -t carpentries/workbench:latest docker
	@$(DOCKER) run --rm -it \
		-v $${PWD}:/lesson \
		-p 4321:4321 \
		carpentries/workbench:latest \
		${R} 'sandpaper::serve(host="0.0.0.0")'
endif

## * clean            : clean up junk files
clean :
	@rm -rf ${DST}

##
## II. Commands specific to workshop websites
## =================================================

##
## III. Commands specific to lesson websites
## =================================================

.PHONY : lesson-check lesson-md lesson-files lesson-fixme install-rmd-deps

# RMarkdown files
RMD_SRC = $(wildcard _episodes_rmd/*.Rmd)
RMD_DST = $(patsubst _episodes_rmd/%.Rmd,_episodes/%.md,$(RMD_SRC))

# Lesson source files in the order they appear in the navigation menu.
MARKDOWN_SRC = \
  index.md \
  CODE_OF_CONDUCT.md \
  setup.md \
  $(sort $(wildcard _episodes/*.md)) \
  reference.md \
  $(sort $(wildcard _extras/*.md)) \
  LICENSE.md

# Generated lesson files in the order they appear in the navigation menu.
HTML_DST = \
  ${DST}/index.html \
  ${DST}/conduct/index.html \
  ${DST}/setup/index.html \
  $(patsubst _episodes/%.md,${DST}/%/index.html,$(sort $(wildcard _episodes/*.md))) \
  ${DST}/reference.html \
  $(patsubst _extras/%.md,${DST}/%/index.html,$(sort $(wildcard _extras/*.md))) \
  ${DST}/license/index.html

## * install-rmd-deps : Install R packages dependencies to build the RMarkdown lesson
install-rmd-deps:
	@${SHELL} bin/install_r_deps.sh

## * lesson-md        : convert Rmarkdown files to markdown
lesson-md : ${RMD_DST}

_episodes/%.md: _episodes_rmd/%.Rmd install-rmd-deps
	@mkdir -p _episodes
	@$(SHELL) bin/knit_lessons.sh $< $@

## * lesson-check     : validate lesson Markdown
lesson-check : python lesson-fixme
	@${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md

## * lesson-check-all : validate lesson Markdown, checking line lengths and trailing whitespace
lesson-check-all : python
	@${PYTHON} bin/lesson_check.py -s . -p ${PARSER} -r _includes/links.md -l -w --permissive

## * unittest         : run unit tests on checking tools
unittest : python
	@${PYTHON} bin/test_lesson_check.py

## * lesson-files     : show expected names of generated files for debugging
lesson-files :
	@echo 'RMD_SRC:' ${RMD_SRC}
	@echo 'RMD_DST:' ${RMD_DST}
	@echo 'MARKDOWN_SRC:' ${MARKDOWN_SRC}
	@echo 'HTML_DST:' ${HTML_DST}

## * lesson-fixme     : show FIXME markers embedded in source files
lesson-fixme :
	@grep --fixed-strings --word-regexp --line-number --no-messages FIXME ${MARKDOWN_SRC} || true

##
## IV. Auxililary (plumbing) commands
## =================================================

.PHONY : commands python

## * commands         : show all commands.
commands :
	@sed -n -e '/^##/s|^##[[:space:]]*||p' $(MAKEFILE_LIST)

python :
ifeq (, $(PYTHON))
	$(error $(PYTHON_NOTE))
else
	@:
endif

index.md :
ifeq (, $(wildcard index.md))
	$(error index.md not found)
else
	@:
endif
