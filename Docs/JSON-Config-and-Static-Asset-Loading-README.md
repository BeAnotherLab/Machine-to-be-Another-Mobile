# JSON Configuration and Static Asset Loading

This document describes the configuration files and external asset-loading pipeline used by **The Machine to Be Another (Mobile)**. It complements [`JSON-Sequencer-README.md`](JSON-Sequencer-README.md), which documents the timeline step format.

The system follows the JSON-Based Timeline Specification in [`JSON-Based Timeline Specification - v2.pdf`](JSON-Based%20Timeline%20Specification%20-%20v2.pdf): configuration and media are kept outside the Unity scene and can be replaced on the headset without rebuilding the application.

> **Implementation note:** this document describes the behavior currently implemented in the repository. The PDF is a specification proposal, so names or capabilities described there that are not represented by the current loader should be treated as future extensions.

## Content package

All runtime content is stored below a top-level `Content/` directory:

```text
Content/
├── Audio/
│   ├── EN/
│   │   ├── welcome.ogg
│   │   └── ...
│   └── FR/
│       └── ...
├── Config/
│   ├── config.json
│   └── sequence.json
├── Font/
│   └── font_color.txt
├── Image/
│   ├── flag_EN.png
│   ├── flag_FR.png
│   ├── panel_background.png
│   └── ...
├── Translation/
│   ├── EN.json
│   └── FR.json
├── Video/
│   └── instructions.mp4
└── Template/
    └── technorama_auto_sequence.json
```

The same logical paths are used in the Unity Editor, Windows builds, and Android builds. `ContentPath` resolves the root as follows:

| Runtime | Content root |
| --- | --- |
| Unity Editor | Project root `/Content` |
| Windows standalone | Build directory `/Content` |
| Android / Quest | `Application.persistentDataPath/Content` |

On Quest, run `copy-content.sh` after installing the APK so the complete `Content` directory exists in persistent storage.

## Configuration files

### `Content/Config/config.json`

`config.json` controls which languages are offered by the experience. Its current schema is:

```json
{
  "selected_languages": ["EN", "FR"]
}
```

#### `selected_languages`

- **Type:** array of strings
- **Required:** yes for language selection
- **Value:** language codes matching flag files, translation files, and audio directories
- **Order:** determines the order in which language buttons are populated; the first valid language becomes the startup language

For example, `"EN"` must have corresponding content such as:

```text
Content/Image/flag_EN.png
Content/Translation/EN.json
Content/Audio/EN/<audio-file>
```

At startup, `DataLoader` discovers available languages by scanning `Content/Image/` for files named `flag_*.png`. Entries in `selected_languages` that do not have a matching discovered flag are ignored. If `config.json` is missing, malformed, empty, or contains no valid language, language initialization cannot complete and the relevant warning/error is written to the log.

### `Content/Config/sequence.json`

`sequence.json` contains the ordered timeline consumed by the JSON sequencer:

```json
{
  "steps": [
    {
      "time": 0.0,
      "textKey": "welcome",
      "audio": "welcome.ogg",
      "actions": ["WallOn"]
    },
    {
      "time": 15.0,
      "visual": "instructions.mp4"
    },
    {
      "time": 15.1,
      "textKey": "blank",
      "actions": ["ShowVisual"]
    }
  ]
}
```

The sequence loader reads the file into `SequenceData` when `DataLoader` starts. The timeline controller then converts each absolute `time` value into an interval from the previous step. Keep steps in ascending order; the array order determines execution order when two steps share a timestamp.

See [`JSON-Sequencer-README.md`](JSON-Sequencer-README.md) for the complete step schema, timing rules, localization behavior, and supported actions.

## Translation loading

Each language has one JSON dictionary at `Content/Translation/<language-code>.json`:

```json
{
  "welcome": "Welcome",
  "position": "Look straight ahead",
  "sit": "Please sit down",
  "blank": ""
}
```

The `textKey` in a sequence is looked up in the dictionary for the active language. Sequence files should contain keys, not participant-facing text. When the language changes, the corresponding dictionary is read again and replaces the active translations.

Guidelines:

- Use the same key in every language that can run the sequence.
- Keep keys stable when translating or revising copy.
- Use valid JSON with double quotes and no trailing commas.
- Treat missing keys as a content error: the instruction cannot be displayed correctly.

## Audio loading

Audio is language-specific and is resolved using:

```text
Content/Audio/<active-language>/<filename>
```

A sequence entry such as:

```json
{
  "time": 0.0,
  "audio": "welcome.ogg"
}
```

loads:

```text
Content/Audio/EN/welcome.ogg
```

The current loader supports:

- `.ogg` using `AudioType.OGGVORBIS`
- `.wav` using `AudioType.WAV`

The filename must include its extension. Audio can also be requested by the TouchOSC/operator controls, using the same active-language path. If a file is absent or has an unsupported extension, the loader logs a warning/error and does not play it.

## Visual loading

Timeline visuals are loaded separately from being shown. This permits a sequence to prepare a visual and display it at a later timestamp:

```json
{
  "time": 15.0,
  "visual": "instructions.mp4"
},
{
  "time": 15.1,
  "actions": ["ShowVisual"]
}
```

The current `VisualPlayer` resolves visuals by file extension:

| Extension | Directory | Runtime behavior |
| --- | --- | --- |
| `.png` | `Content/Image/` | Reads bytes, creates a `Texture2D`, and displays it as a `Sprite`. |
| `.mp4` | `Content/Video/` | Sets the `VideoPlayer.url` to the file path and plays the video. |

Use `HideVisual` to hide the visual layer and stop video playback. A visual is not automatically hidden when a new sequence step runs; hide/show behavior must be expressed explicitly through actions.

## Static UI assets

Static assets are loaded directly from the content package during scene initialization rather than being embedded in the Unity scene.

### Images

`Content/Image/` contains PNG assets used by the UI and language selection, including:

- `flag_<language-code>.png` — language button graphics and language discovery markers
- `panel_background.png` — instruction panel background
- `start_button_off.png` and `start_button_on.png` — confirmation button graphics
- other PNG files referenced by the scene-specific loaders or by `visual` sequence steps

Image loaders read the file bytes with `File.ReadAllBytes`, create a Unity texture, and assign it to a `Sprite`, `Image`, or material. File names are case-sensitive on Android; use the exact file name in the content package and JSON.

### Fonts and text styling

The current external font configuration uses:

```text
Content/Font/font_color.txt
```

The file contains a Unity-compatible HTML color value, for example:

```text
#FFFFFF
```

The font color loader trims the file contents and applies the parsed color to the target TextMeshPro component. Invalid values are reported in the log and leave the existing color unchanged.

### Other directories

`ContentPath` also exposes paths for `Config`, `Font`, `Image`, `Video`, `Audio`, and `Translation`. Keep new externally loaded asset types in one of these directories and add a dedicated loader when the asset requires processing beyond raw file or URL loading.

## Loading lifecycle

The normal startup order is:

1. `DataLoader` loads `Content/Config/sequence.json` into `SequenceData`.
2. `DataLoader` scans `Content/Image/` for `flag_*.png` files.
3. `Content/Config/config.json` is read.
4. Invalid language selections are removed.
5. Language buttons are populated from the remaining language codes.
6. The first valid language is loaded from `Content/Translation/<code>.json` and becomes active.
7. The sequence starts when the experience's readiness conditions are met.
8. Each timeline step updates text, requests audio, loads visuals, and executes actions in the order defined by the sequence.

The package is file-based rather than an Addressables or Resources catalog. Therefore, changing JSON or replacing supported content files normally does not require a Unity rebuild, but the changed files must be copied to the headset again.

## Authoring and validation checklist

Before copying a content package to a headset:

- [ ] `Content/Config/config.json` is valid JSON.
- [ ] `selected_languages` contains at least one intended language code.
- [ ] Every selected language has a matching `flag_<code>.png`.
- [ ] Every selected language has a matching `Translation/<code>.json`.
- [ ] Audio referenced by the sequence exists under every language that can run it.
- [ ] Audio uses `.ogg` or `.wav` and includes the extension in the sequence.
- [ ] Image visuals are `.png` files in `Content/Image/`.
- [ ] Video visuals are `.mp4` files in `Content/Video/`.
- [ ] Every `textKey` exists in each required translation dictionary.
- [ ] Sequence times are ascending and the `steps` array is not empty.
- [ ] JSON contains no comments or trailing commas.
- [ ] File and directory casing matches the references exactly.
- [ ] `./copy-content.sh` has been run after the content was changed.

## Troubleshooting

### The app reports that a file is missing

Check the resolved path in the Unity log and confirm that the file exists under the active `Content` root. On Quest, verify the file was copied to `Application.persistentDataPath/Content`, not only left in the project checkout.

### No language buttons appear

Confirm that `Content/Image/` exists and that flags use the exact `flag_<code>.png` naming convention. Then check that the same codes are listed in `selected_languages`.

### Audio does not play

Confirm the active language, exact filename, extension, and directory. `.ogg` files must be Vorbis-compatible, and `.wav` files must be supported by Unity's audio loader.

### A visual loads but does not appear

Loading and display are separate operations. Add `ShowVisual` after the `visual` step, and use `HideVisual` when the visual should stop. For video, also verify that the file is in `Content/Video/` and uses the `.mp4` extension.

### Changes are not visible on the headset

Re-run `copy-content.sh` after editing the package. Restart the application if a file was already loaded; currently loaded textures, videos, translations, and sequence data are not automatically hot-reloaded.

## Related implementation files

- [`Assets/Scripts/FileLoading/ContentPath.cs`](../Assets/Scripts/FileLoading/ContentPath.cs) — resolves platform-specific content paths
- [`Assets/Scripts/FileLoading/DataLoader.cs`](../Assets/Scripts/FileLoading/DataLoader.cs) — loads JSON configuration, sequences, languages, translations, and audio
- [`Assets/Scripts/UI/VisualPlayer.cs`](../Assets/Scripts/UI/VisualPlayer.cs) — loads and displays PNG and MP4 visuals
- [`Assets/Scripts/FileLoading/LanguageButtonsLoader.cs`](../Assets/Scripts/FileLoading/LanguageButtonsLoader.cs) — loads language flags
- [`Assets/Scripts/FileLoading/PanelBackgroundLoader.cs`](../Assets/Scripts/FileLoading/PanelBackgroundLoader.cs) — loads the panel background
- [`Assets/Scripts/FileLoading/ConfirmationButtonGraphicsLoader.cs`](../Assets/Scripts/FileLoading/ConfirmationButtonGraphicsLoader.cs) — loads confirmation button textures
- [`Assets/Scripts/FileLoading/InstructionsTextFontLoader.cs`](../Assets/Scripts/FileLoading/InstructionsTextFontLoader.cs) — loads external font color configuration
- [`Assets/Scripts/JSONSequencing/JsonSequenceController.cs`](../Assets/Scripts/JSONSequencing/JsonSequenceController.cs) — executes timeline steps
- [`Docs/JSON-Sequencer-README.md`](JSON-Sequencer-README.md) — timeline schema and actions
