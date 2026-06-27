SHELL := /bin/bash

COMPOSE := docker compose -f docker/docker-compose.yml
RUN := $(COMPOSE) run --rm slides

LATEX_ENGINE ?= lualatex
LATEXMK_FLAGS ?= -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1
PDFPC_OPTS ?=
PDFPC_CONFIG_HOME ?= /opt/pdfpc-config
PDFPC_NOTES_POSITION ?=
PDFPC_WINDOWED_MODE ?= both
PDFPC_PRESENTATION_SCREEN ?=
PDFPC_PRESENTER_SCREEN ?=
PROJECT ?=
TEXFILE ?= main.tex
WORKSPACE_ROOT ?= $(CURDIR)
PROJECT_DIR ?= $(WORKSPACE_ROOT)/projects/$(PROJECT)
ifneq ($(filter command line environment,$(origin TEX)),)
TEXFILE := $(TEX)
endif

.DEFAULT_GOAL := help

.PHONY: help build up down shell compile watch present present-windowed present-dual-screen clean

build: ## Build the Docker image
	$(COMPOSE) build

up: ## Start a reusable container in the background
	xhost +local:docker >/dev/null 2>&1 || true
	$(COMPOSE) up -d

down: ## Stop the reusable container
	$(COMPOSE) down
	xhost -local:docker >/dev/null 2>&1 || true

shell: ## Open a shell in a fresh container
	$(RUN) bash

compile: ## Compile a LaTeX project (make compile PROJECT=demo [TEXFILE=slides.tex])
ifndef PROJECT
	$(error PROJECT is not set. Usage: make compile PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		case "$(LATEX_ENGINE)" in \
			pdflatex) latexmk -pdf $(LATEXMK_FLAGS) "$$texfile" ;; \
			xelatex) latexmk -xelatex $(LATEXMK_FLAGS) "$$texfile" ;; \
			lualatex|*) latexmk -lualatex $(LATEXMK_FLAGS) "$$texfile" ;; \
		esac'

watch: ## Watch and rebuild on file changes (make watch PROJECT=demo)
ifndef PROJECT
	$(error PROJECT is not set. Usage: make watch PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		case "$(LATEX_ENGINE)" in \
			pdflatex) latexmk -pdf -pvc -view=none $(LATEXMK_FLAGS) "$$texfile" ;; \
			xelatex) latexmk -xelatex -pvc -view=none $(LATEXMK_FLAGS) "$$texfile" ;; \
			lualatex|*) latexmk -lualatex -pvc -view=none $(LATEXMK_FLAGS) "$$texfile" ;; \
		esac'

present: ## Compile and launch pdfpc (make present PROJECT=demo)
ifndef PROJECT
	$(error PROJECT is not set. Usage: make present PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		case "$(LATEX_ENGINE)" in \
			pdflatex) latexmk -pdf $(LATEXMK_FLAGS) "$$texfile" ;; \
			xelatex) latexmk -xelatex $(LATEXMK_FLAGS) "$$texfile" ;; \
			lualatex|*) latexmk -lualatex $(LATEXMK_FLAGS) "$$texfile" ;; \
		esac; \
		XDG_CONFIG_HOME="$(PDFPC_CONFIG_HOME)" pdfpc $(PDFPC_OPTS) $(if $(PDFPC_NOTES_POSITION),--notes=$(PDFPC_NOTES_POSITION)) "$${texfile%.tex}.pdf"'

present-windowed: ## Compile and launch pdfpc in windowed mode (make present-windowed PROJECT=demo)
ifndef PROJECT
	$(error PROJECT is not set. Usage: make present-windowed PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		case "$(LATEX_ENGINE)" in \
			pdflatex) latexmk -pdf $(LATEXMK_FLAGS) "$$texfile" ;; \
			xelatex) latexmk -xelatex $(LATEXMK_FLAGS) "$$texfile" ;; \
			lualatex|*) latexmk -lualatex $(LATEXMK_FLAGS) "$$texfile" ;; \
		esac; \
		XDG_CONFIG_HOME="$(PDFPC_CONFIG_HOME)" pdfpc $(PDFPC_OPTS) $(if $(PDFPC_NOTES_POSITION),--notes=$(PDFPC_NOTES_POSITION)) --windowed=$(PDFPC_WINDOWED_MODE) "$${texfile%.tex}.pdf"'

present-dual-screen: ## Compile and launch pdfpc using two monitors (make present-dual-screen PROJECT=demo)
ifndef PROJECT
	$(error PROJECT is not set. Usage: make present-dual-screen PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		case "$(LATEX_ENGINE)" in \
			pdflatex) latexmk -pdf $(LATEXMK_FLAGS) "$$texfile" ;; \
			xelatex) latexmk -xelatex $(LATEXMK_FLAGS) "$$texfile" ;; \
			lualatex|*) latexmk -lualatex $(LATEXMK_FLAGS) "$$texfile" ;; \
		esac; \
		screen_args=""; \
		if [ -n "$(PDFPC_PRESENTER_SCREEN)" ]; then screen_args="$$screen_args -1 $(PDFPC_PRESENTER_SCREEN)"; fi; \
		if [ -n "$(PDFPC_PRESENTATION_SCREEN)" ]; then screen_args="$$screen_args -2 $(PDFPC_PRESENTATION_SCREEN)"; fi; \
		XDG_CONFIG_HOME="$(PDFPC_CONFIG_HOME)" pdfpc $(PDFPC_OPTS) $(if $(PDFPC_NOTES_POSITION),--notes=$(PDFPC_NOTES_POSITION)) $$screen_args "$${texfile%.tex}.pdf"'

clean: ## Remove LaTeX build artifacts (make clean PROJECT=demo)
ifndef PROJECT
	$(error PROJECT is not set. Usage: make clean PROJECT=my_talk)
endif
	$(RUN) bash -lc '\
		set -euo pipefail; \
		cd "$(PROJECT_DIR)"; \
		texfile="$(TEXFILE)"; \
		if { [ -z "$$texfile" ] || { [ "$$texfile" = "main.tex" ] && [ ! -f "$$texfile" ]; }; }; then \
			if [ -f main.tex ]; then \
				texfile=main.tex; \
			else \
				texfile="$$(find . -maxdepth 1 -name "*.tex" | sort | head -n 1)"; \
			fi; \
		fi; \
		if [ -z "$$texfile" ] || [ ! -f "$$texfile" ]; then \
			echo "No TeX file found in $(PROJECT_DIR). Set TEXFILE=..."; \
			exit 1; \
		fi; \
		latexmk -C "$$texfile"'

help: ## Show this help
	@echo ""
	@echo "pdfpc Docker workspace"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
