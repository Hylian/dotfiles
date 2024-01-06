#!/bin/zsh
if [[ -z $(pidof -x chromium) ]]; then gio launch ~/.local/share/applications/home-assistant.desktop; fi
