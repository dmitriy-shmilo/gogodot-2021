NAME_OVERRIDE := "rearguard"
PROJECT_NAME = $(or $(NAME_OVERRIDE), $(notdir $(CURDIR)))
GODOT = "/Applications/Godot.app/Contents/MacOS/Godot"

all: html mac linux windows

html html5:
	$(GODOT) --path src/ --export "HTML5" "../build/index.html"; \
	cd build/; \
	zip -X "$(PROJECT_NAME).web.zip" "favicon.png" "index.html" "index.js" "index.pck" "index.png" "index.wasm"; \
	rm -f "favicon.png" "index.html" "index.js" "index.pck" "index.png" "index.wasm"

mac macos:
	$(GODOT) --path src/ --export "Mac OSX" "../build/$(PROJECT_NAME).dmg"; \
	cd build/; \
	zip -X "$(PROJECT_NAME).macos.zip" "$(PROJECT_NAME).dmg"; \
	rm -f "$(PROJECT_NAME).dmg"

linux:
	$(GODOT) --path src/ --export "Linux/X11" "../build/$(PROJECT_NAME).x86_64"; \
	cd build/; \
	zip -X "$(PROJECT_NAME).linux.zip" "$(PROJECT_NAME).x86_64"; \
	rm -f "$(PROJECT_NAME).x86_64"

win windows:
	$(GODOT) --path src/ --export "Windows Desktop" "../build/$(PROJECT_NAME).exe"; \
	cd build/; \
	zip -X "$(PROJECT_NAME).win.zip" "$(PROJECT_NAME).exe"; \
	rm -f "$(PROJECT_NAME).exe"

clean:
	rm -f build/*
	rm -f logs/*

setup:
	@echo "Setting project name..."
	sed -i.bak -e "s/config\/name=\"godot-template\"/config\/name=\"$(PROJECT_NAME)\"/g" src/project.godot

	@echo "Setting export names..."
	sed -i.bak -e "s/godot-template/$(PROJECT_NAME)/g" src/export_presets.cfg

	@echo "Deleting backups..."
	rm -f src/*.bak