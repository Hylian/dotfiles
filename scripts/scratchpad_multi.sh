#!/bin/zsh
#if [[ -z $(pidof -x plexamp) ]]; then /usr/bin/Plexamp.AppImage --enable-features=UseOzonePlatform --ozone-platform=wayland &; fi
if [[ -z $(pidof -x plexamp) ]]; then /usr/bin/Plexamp.AppImage --enable-features=UseOzonePlatform &; fi
if [[ -z $(pidof -x chromium) ]]; then gio launch ~/.local/share/applications/home-assistant.desktop; fi
