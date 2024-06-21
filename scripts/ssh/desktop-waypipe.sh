#!/bin/sh
/usr/local/bin/waypipe -n --threads 4 ssh -t desktop "zsh -c 'printenv WAYLAND_DISPLAY > /tmp/wayland_display && zellij -s persist || zellij a persist'"
