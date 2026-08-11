# Disabling Zellij Trackpad Inertial Scrolling ٩(◕‿◕｡)۶

*Date: 2026-08-11*

## Motivation & Context

In Zellij, fast trackpad swipes previously accumulated momentum via dynamic logarithmic acceleration (`scroll_acceleration_factor 3.5`), giving an inertial fling/coasting feel.

Rachel requested disabling inertial scrolling so that trackpad wheel events map strictly 1:1 to viewport scrolling without acceleration impulses or inertial coasting after releasing the gesture.

## Configuration Change

In [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl):
- Changed `scroll_acceleration_factor 3.5` to `scroll_acceleration_factor 1.0`.

```kdl
// Max acceleration multiplier for continuous trackpad/mouse wheel scrolling
// Default: 3.5 (1.0 to disable acceleration)
//
scroll_acceleration_factor 1.0
```

## Mechanism in `Hylian/zellij`

In `zellij-server/src/tab/mouse_handler.rs`:
- Flick detection is gated on `tab.scroll_acceleration_factor > 1.0`.
- Setting `scroll_acceleration_factor 1.0` evaluates `is_flick = false`, suppressing momentum impulse accumulation (`impulse_for_queue = 0.0`) and preventing post-gesture inertial drainage while retaining single-line event precision.

## Verification

- Ran `chezmoi apply` to render `~/.config/zellij/config.kdl`.
- Validated configuration syntax with `zellij setup --check` (`[CONFIG FILE]: Well defined.`).
