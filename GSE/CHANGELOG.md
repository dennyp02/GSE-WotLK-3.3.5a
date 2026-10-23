# GSE2: Gnome Sequencer Enhanced

## 2.2.06-wotlk

- Isolated GSE's bundled AceGUI as `GSE-AceGUI-3.0` so ElvUI and other addons can no longer override GSE's editor widgets.
- Moved the out-of-combat save queue onto a private OnUpdate ticker instead of the shared AceTimer library.
- Added missing enUS localization strings, including the `New: Type ` message.
- Added an in-addon sanitizer that removes invalid sequence entries on login and via `/gse repair`.
- Normalized sequence names so generated names no longer create empty placeholder entries.
- Fixed manual saves being ignored after the first save.
- Hardened sequence loops against invalid saved entries.
- Rebuilt the sequence editor's TabGroup widget (manual tab textures + local panel-template helpers) so tabs render as connected horizontal tabs instead of disconnected/frozen pieces.
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