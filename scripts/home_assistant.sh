#!/bin/zsh
if [[ -z $(pidof -x chrome) ]]; then gio launch ~/.local/share/applications/chrome-diomlfcjikmegkfgnmbolnocfpjnfmon-Default.desktop; fi
