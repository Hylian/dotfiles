#!/bin/sh

sudo update-desktop-databse
sudo cp /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu
kbuildsycoca6 --noincremental
