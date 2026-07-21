# Theme Zsh Vi Mode Visual Selection to Everforest ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
Visual mode selections in `zsh-vi-mode` (`zvm`) defaulted to a harsh bright red background (`#cc0000`), which clashed with the warm organic aesthetic of the Everforest Light theme.

## Fix
1. **Everforest Visual Selection Palette:**
   Updated `dot_zshrc.tmpl` (`zvm_config` and global environment) to configure `zsh-vi-mode` highlight variables:
   - **Everforest Light:**
     - `ZVM_VI_HIGHLIGHT_BACKGROUND="#e5e8c5"` (soft organic sage green)
     - `ZVM_VI_HIGHLIGHT_FOREGROUND="#5c6a72"` (charcoal forest gray text)
     - `ZVM_VI_HIGHLIGHT_EXTRASTYLE="bold"`
   - **Everforest Dark Fallback:**
     - `ZVM_VI_HIGHLIGHT_BACKGROUND="#374145"`
     - `ZVM_VI_HIGHLIGHT_FOREGROUND="#d3c6aa"`
2. **Applied & Documented:** Applied via `chezmoi apply` and updated living ground truth in `notes/SYSTEM.md`.
