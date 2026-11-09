# sim: shortcuts for the iOS Simulator (files, photos, clipboard, app containers).
# Run through the `sim` command that install.sh puts in ~/.local/bin.
# Paths in F are relative to the folder you run `sim` from.

SIM_VERSION := 1.0.0

.DEFAULT_GOAL := help

# Which simulator to use: "booted", a UDID, or a device name, e.g. SIM="iPhone 17 Pro".
SIM ?= booted

# Your app names live here, outside this file, so updates never overwrite them.
SIM_CONFIG ?= $(HOME)/.config/sim/config.mk
-include $(SIM_CONFIG)

# Apps targeted by list/cache/dir/size: app names after the command
# (sim cache dev prod), else APP=<names or bundle ids>, else every name in the config.
APPS     = $(or $(APP),$(filter $(FLAVORS),$(MAKECMDGOALS)),$(FLAVORS))
_BUNDLES = $(strip $(foreach a,$(APPS),$(or $(FLAVOR_$(a)),$(a))))

_COMMANDS := help version config file photo open ls paste list cache dir size
.PHONY: $(_COMMANDS) _unknown

# App names are arguments, not commands.
ifneq ($(strip $(FLAVORS)),)
.PHONY: $(FLAVORS)
$(FLAVORS):
	@:
endif

# Stop on a typo before any command runs, instead of make's "No rule to make target".
_UNKNOWN := $(filter-out $(_COMMANDS) $(FLAVORS),$(MAKECMDGOALS))
ifneq ($(_UNKNOWN),)
$(_COMMANDS) $(_UNKNOWN): _unknown
_unknown:
	@echo "✘ Unknown command or app name: $(_UNKNOWN). Run 'sim' to see the commands."; exit 1
endif

# Loop over each targeted app installed on $(SIM), with $$bid and $$dir set.
# Close the loop with $(_END_EACH_APP).
_EACH_APP = \
	[ -n "$(_BUNDLES)" ] || { echo "✘ No app given. Pass APP=<bundle id>, or name your apps with: sim config"; exit 1; }; \
	found=0; \
	for bid in $(_BUNDLES); do \
		case "$$bid" in *.*) ;; *) echo "✘ Unknown app name '$$bid' (known: $(or $(FLAVORS),none)). Add it with: sim config"; continue;; esac; \
		dir="$$(xcrun simctl get_app_container "$(SIM)" "$$bid" data 2>/dev/null)"; \
		[ -n "$$dir" ] && [ -d "$$dir" ] || continue; \
		found=1;
_END_EACH_APP = done; \
	[ $$found = 1 ] || { echo "✘ None of '$(APPS)' is installed on SIM=$(SIM)"; exit 1; }

# Folder behind Files › On My iPhone, looked up at run time so no UDID is hardcoded.
_FILES_DIR = xcrun simctl get_app_container "$(SIM)" com.apple.DocumentsApp groups 2>/dev/null \
	| awk -F'\t' '$$1 == "group.com.apple.FileProvider.LocalStorage" { print $$2 "/File Provider Storage" }'

# Sets $$dir to the Files › On My iPhone folder, or stops.
_NEED_FILES_DIR = \
	dir="$$($(_FILES_DIR))"; \
	[ -d "$$dir" ] || { echo "✘ No simulator for SIM=$(SIM). Boot one first."; exit 1; }

# Sets $$f to F with a leading ~ expanded (zsh keeps it literal in F=~/...), or stops.
_NEED_F = \
	[ -n "$(F)" ] || { echo "✘ Usage: sim $@ F=<path>"; exit 1; }; \
	f="$$(printf '%s' "$(F)" | sed "s|^~/|$$HOME/|")"; \
	[ -e "$$f" ] || { echo "✘ Not found: $$f"; exit 1; }

help:
	@echo "Files"
	@echo "  sim file  F=<path>   Copy a file or a whole folder into Files › On My iPhone"
	@echo "  sim photo F=<path>   Add an image or video to the Photos app"
	@echo "  sim open             Open Files › On My iPhone in Finder (drag files or folders in)"
	@echo "  sim ls               List what is in Files › On My iPhone"
	@echo ""
	@echo "Clipboard"
	@echo "  sim paste            Copy the Mac clipboard to the simulator clipboard"
	@echo "                       (needs Device Hub 'Use Shared Clipboard' off)"
	@echo ""
	@echo "App containers (every app in your config, or name some: sim cache dev)"
	@echo "  sim list  [name]     Show installed apps and their data container"
	@echo "  sim cache [name]     Open each app's Library/Caches in Finder"
	@echo "  sim dir   [name]     Open each app's data container in Finder"
	@echo "  sim size  [name]     Sizes of each app's Caches, tmp and Documents"
	@echo ""
	@echo "Setup"
	@echo "  sim config           Show (and create) your app names file"
	@echo "  sim version          Show the installed version"
	@echo ""
	@echo "Apps:    $(or $(foreach a,$(FLAVORS),$(a)=$(FLAVOR_$(a))),none yet (run: sim config))"
	@echo "Options: SIM=\"iPhone 17 Pro\" (or a UDID, default: booted)  APP=<bundle id>"

version:
	@echo "sim $(SIM_VERSION)"

config:
	@if [ ! -f "$(SIM_CONFIG)" ]; then \
		mkdir -p "$$(dirname "$(SIM_CONFIG)")" && \
		printf '%s\n' \
			'# sim config: short names for your apps, so you can type `sim cache dev`.' \
			'# FLAVORS lists the names; FLAVOR_<name> gives each one its bundle id.' \
			'# Uncomment and edit:' \
			'#' \
			'# FLAVORS := dev prod' \
			'# FLAVOR_dev  := com.example.app.dev' \
			'# FLAVOR_prod := com.example.app' \
			> "$(SIM_CONFIG)" && \
		echo "✔ Created $(SIM_CONFIG)"; \
	fi; \
	echo "Edit: $(SIM_CONFIG)"; echo ""; cat "$(SIM_CONFIG)"

file:
	@$(_NEED_F); $(_NEED_FILES_DIR); \
	cp -R "$$f" "$$dir/" && echo "✔ Copied $$(basename "$$f") → Files › On My iPhone"

photo:
	@$(_NEED_F); \
	xcrun simctl addmedia "$(SIM)" "$$f" && echo "✔ Added $$(basename "$$f") → Photos"

open:
	@$(_NEED_FILES_DIR); open "$$dir"

ls:
	@$(_NEED_FILES_DIR); ls -lA "$$dir"

# Device Hub's "Use Shared Clipboard" overwrites this copy with its own synced
# item (tagged dtpasteboardd.sync), so warn when that tag is still there.
paste:
	@pbpaste | xcrun simctl pbcopy "$(SIM)" || exit 1; \
	sleep 1; \
	if xcrun simctl pbinfo "$(SIM)" 2>/dev/null | grep -q 'dtpasteboardd.sync'; then \
		echo "⚠ Device Hub 'Use Shared Clipboard' is on and replaced this copy."; \
		echo "  Turn it off in Device Hub and run again, or press Paste twice in the app."; \
	else \
		echo "✔ Mac clipboard → simulator clipboard"; \
	fi

list:
	@$(_EACH_APP) printf '%s\t%s\n' "$$bid" "$$dir"; $(_END_EACH_APP)

cache:
	@$(_EACH_APP) echo "$$bid"; open "$$dir/Library/Caches"; $(_END_EACH_APP)

dir:
	@$(_EACH_APP) echo "$$bid"; open "$$dir"; $(_END_EACH_APP)

size:
	@$(_EACH_APP) \
		echo "== $$bid  $$dir"; \
		du -sh "$$dir"/Library/Caches/* "$$dir"/tmp "$$dir"/Documents 2>/dev/null | sort -rh; \
	$(_END_EACH_APP)
