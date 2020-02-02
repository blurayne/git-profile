SHELL:=/bin/bash ./Makeshell
HOME?=$$HOME
.DEFAULT_GOAL=help
.PHONY: help -phony

BIN_PATH=$(HOME)/.local/bin
CONIFG_PATH=$(HOME)/.config/git
ifeq ($(USER),root)
	HOME=/root
	BIN_PATH=/usr/local/bin
	CONIFG_PATH=$(HOME)/.config/git
endif
GROUP=$(shell id -gn $(USER))
PWD=$(shell pwd)

##@ Helpers

help:  ## Display this help
	 @usage $(MAKEFILE_LIST)

info:  ## Info
	# source functions.sh && hello-world 1
	@echo -e \
		  "PWD       : $(PWD)" \
		"\nHOME      : $(HOME)" \
		"\nUSER      : $(USER)" \
		"\nGROUP     : $(GROUP)" \
		"\nBIN_PATH  : $(BIN_PATH)" 

##@ Installation

install: ## Install everything
	@if [[ ! -d "$(BIN_PATH)" ]]; then mkdir -vp -m 755 "$(BIN_PATH)"; fi
	@if [[ ! -d "$(CONIFG_PATH)/hooks" ]]; then mkdir -vp -m 755 "$(CONIFG_PATH)/hooks"; fi
	@find bin -type f -not -name ".gitignore" -printf '%P\n' | xargs -I {} install -C  -vo $(USER) -g $(GROUP) --mode=0755 -v "bin/{}" "$(BIN_PATH)/{}"
	@find hooks -type f -not -name ".gitignore" -printf '%P\n' | xargs -I {} install -C --backup -S '-original'  -vo $(USER) -g $(GROUP) --mode=0755 -v "hooks/{}" "$(CONIFG_PATH)/hooks/{}"
	
	@if ! grep -q "GIT_SSH=" $$HOME/.profile; then \
		echo "export GIT_SSH=\"$$HOME/.local/bin/git-profile-ssh-wrapper\"" >> $$HOME/.profile; \
		echo -e "'export GIT_SSH' was added to your profile. Please restart shell and make sure 'env | grep GIT_SSH' does exist\!"; \
	fi
	@if find "$(CONIFG_PATH)/hooks/" -type f -not -name "-original" 1>/dev/null 2>&1; then \
		echo -e "Some git hooks were overwritten! Please review $(CONIFG_PATH)/hooks!"; \
	fi
	@echo 
	@echo "Everything finished."
