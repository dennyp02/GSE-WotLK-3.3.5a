# Positive Changes — GSE WotLK 3.3.5a (for later README integration)

Working notes of successful additions/changes made on top of the original backport.
The existing `GSE/CHANGELOG.md` stays as-is; this file is a staging list for the README.

## Core sequence / save logic

- **Saved-data sanitizer**: `GSE.SanitizeSequenceLibrary()` removes invalid `GSELibrary` entries (non-tables / missing `MacroVersions`) and migrates valid sequences stored under spaced names to normalized keys. Runs on login and via `/gse repair`.
- **Sequence name normalization**: `GSE.NormalizeSequenceName()` trims and replaces spaces/commas with `_`. Used for generated names, editor saves, and the OOC queue, preventing empty-string placeholder keys and duplicate sequence entries.
- **Manual save overwrite fix**: editor saves now overwrite the stored sequence using the incoming `ManualIntervention` flag instead of the stale stored flag, so subsequent edits are no longer silently ignored.
- **Save-path cleanup**: `ProcessOOCQueue` `"Replace"` no longer creates `''` placeholders, validates sequence data, and cleans up old/normalized name keys.
- **Defensive guards**: all `MacroVersions` loops are type-guarded so one corrupt saved entry can no longer break login or the editor.
- **Missing enUS strings** added (including `New: Type ` and the `/gse repair` help).
- **`/gse repair`** command to force a library re-sanitize.

## UI / editor

- **Private AceGUI namespace**: `GSE-AceGUI-3.0` isolates GSE's GUI from ElvUI/other addons overriding its widgets.
- **Vendored complete AceGUI 3.0 set**: consistent core 42 + all 22 standard widgets, with **GSE-prefixed frame names** so they cannot collide with the real AceGUI instance's frames (the cause of broken dropdowns/tabs).
- **Editor/Viewer content sizing**: frame content area is synchronized on show/resize; tab content is rebuilt safely (debounced) so fields fit.
- **Resize handling**: uses AceGUI's own `OnSizeChanged` via `HookScript` (not replacing it), so tabs, toolbar, and the bottom button row stay correctly laid out after resizing.
- **TabGroup**: renders as connected horizontal top tabs.
- **Dropdowns**: full body + working arrow (fixed by the consistent widget set + namespacing).
- **Static popups**: all GSE popups (delete/import/sample/debug/reload/etc.) are raised above the editor/viewer so confirmations are never hidden behind an AceGUI window.
- **Private OOC ticker**: out-of-combat save queue runs on its own `OnUpdate` frame instead of the shared AceTimer library.

## Metadata

- Version bumped to `2206-wotlk` across all TOCs.
- Rollback points: branch `backup/pre-acegui-vendor`, tag `pre-acegui-vendor`.
