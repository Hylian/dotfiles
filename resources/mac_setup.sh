#!/bin/dash

# Drag windows with control + cmd
defaults write -g NSWindowShouldDragOnGesture -bool true
# Don't play animation when dragging
defaults write -g NSWindowShouldDragOnGestureFeedback -bool false
# Disable window opening animations
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
# Don't animate opening applications from dock
defaults write com.apple.dock launchanim -bool false
# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1
# Remove Dock auto-hide delay
defaults write com.apple.dock autohide-delay -float 0
# Remove Dock show/hide animation
defaults write com.apple.dock autohide-time-modifier -float 0
# Speed up window resize for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

killAll Finder && killAll Dock
