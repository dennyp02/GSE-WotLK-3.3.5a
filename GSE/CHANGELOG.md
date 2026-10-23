# GSE2: Gnome Sequencer Enhanced

## 2.2.06-wotlk

- Isolated GSE's bundled AceGUI as `GSE-AceGUI-3.0` so ElvUI and other addons can no longer override GSE's editor widgets.
- Moved the out-of-combat save queue onto a private OnUpdate ticker instead of the shared AceTimer library.
- Added missing enUS localization strings, including the `New: Type ` message.
- Added an in-addon sanitizer that removes invalid sequence entries on login and via `/gse repair`.
- Normalized sequence names so generated names no longer create empty placeholder entries.
- Fixed manual saves being ignored after the first save.
- Hardened sequence loops against invalid saved entries.
- Vendored a complete, consistent AceGUI 3.0 set (core + all standard widgets) into the private `GSE-AceGUI-3.0` namespace, replacing the mixed old-core/new-widget setup. All private frame names are `GSE`-prefixed so they cannot collide with the real AceGUI instance's frames. Fixes the editor's tab strip and the dropdowns that rendered only their left edge or had a dead arrow.
- Requires in-game verification with ElvUI enabled and disabled.

## [2.6.55](https://github.com/TimothyLuke/GnomeSequencer-Enhanced/tree/2.6.55) (2021-06-09)
[Full Changelog](https://github.com/TimothyLuke/GnomeSequencer-Enhanced/compare/2.6.54...2.6.55) [Previous Releases](https://github.com/TimothyLuke/GnomeSequencer-Enhanced/releases)

- #846 Update ranks to internal API  
- #846 Dont print pcall passed  
- #846 Use GetSpellSubtext to obtain rank information.  
- #841  
    Build on Tag  
- #841 Update CI.yml  
- Migrate from Travis to Google Actions  