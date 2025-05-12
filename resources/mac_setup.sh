# Drag windows with control + cmd
defaults write -g NSWindowShouldDragOnGesture -bool true
# Don't play animation when dragging
defaults write -g NSWindowShouldDragOnGestureFeedback -bool false
# Disable window opening animations
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
