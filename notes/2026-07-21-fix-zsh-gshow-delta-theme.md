# Fix Zsh gshow & Delta Theme Alignment ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
The `gshow` alias and `git-pick-fzf` widget were using `delta --true-color always -n --no-gitconfig` without theme awareness. Because delta defaults to a dark background when unconfigured, the preview window rendered dark theme highlights over an Everforest Light terminal session.

## Fix Details
1. **Chezmoi Template Conversion:** Converted `dot_config/zsh/aliases` and `dot_config/zsh/widgets` into `.tmpl` files (`dot_config/zsh/aliases.tmpl` and `dot_config/zsh/widgets.tmpl`).
2. **Dynamic Delta Options:** Updated `fzf-git-pick-commit` preview to dynamically pass `--light --syntax-theme=OneHalfLight` when `.theme` is not `dark`, and `--dark --syntax-theme=TwoDark` when `.theme` is `dark`.
3. **Harmonized Widget FZF Colors:** Templated `zoxide-fzf` and `zoxide-fzf-curdir` options to align with the active `.theme`.
4. **Validated & Applied:** Applied via `chezmoi apply`, verified clean syntax highlighting and background rendering in `~/.config/zsh/aliases` and `~/.config/zsh/widgets`.
