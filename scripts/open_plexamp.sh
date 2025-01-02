#!/bin/zsh
if [[ -z $(pidof -x plexamp) ]]; then $HOME/.local/bin/Plexamp-4.6.1.AppImage --enable-features=UseOzonePlatform --ozone-platform=wayland &; fi
