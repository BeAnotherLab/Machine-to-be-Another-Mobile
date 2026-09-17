# JSON Configuration and Static Asset Loading

This document describes the configuration files and external asset-loading pipeline used by **The Machine to Be Another (Mobile)**. It complements [`JSON-Sequencer-README.md`](JSON-Sequencer-README.md), which documents the timeline step format. Configuration and media are kept outside the Unity scene and can be replaced on the headset without rebuilding the application.

## Related implementation files
 
- [`Assets/Scripts/FileLoading/ContentPath.cs`](../Assets/Scripts/FileLoading/ContentPath.cs) — resolves platform-specific content paths
- [`Assets/Scripts/FileLoading/DataLoader.cs`](../Assets/Scripts/FileLoading/DataLoader.cs) — loads JSON configuration, sequences, languages, translations, and audio
- [`Assets/Scripts/FileLoading/LanguageButtonsLoader.cs`](../Assets/Scripts/FileLoading/LanguageButtonsLoader.cs) — loads language flags
- [`Assets/Scripts/FileLoading/PanelBackgroundLoader.cs`](../Assets/Scripts/FileLoading/PanelBackgroundLoader.cs) — loads the panel background
- [`Assets/Scripts/FileLoading/ConfirmationButtonGraphicsLoader.cs`](../Assets/Scripts/FileLoading/ConfirmationButtonGraphicsLoader.cs) — loads confirmation button textures
- [`Assets/Scripts/FileLoading/InstructionsTextFontLoader.cs`](../Assets/Scripts/FileLoading/InstructionsTextFontLoader.cs) — loads external font color configuration


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

For example, `"EN"` must have corresponding content such as:

```text
Content/Image/flag_EN.png
Content/Translation/EN.json
Content/Audio/EN/<audio-file>
```

At startup, `DataLoader` discovers available languages by scanning `Content/Image/` for files named `flag_*.png`. Entries in `selected_languages` that do not have a matching discovered flag are ignored. If `config.json` is missing, malformed, empty, or contains no valid language, language initialization cannot complete. You can load either 2 or 4 languages for the flags to be displayed properly on the interface.

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

## Audio loading

Audio is language-specific and is resolved using:

```text
Content/Audio/<active-language>/<filename>
```

The current loader supports:

- `.ogg` using `AudioType.OGGVORBIS`
- `.wav` using `AudioType.WAV`

The filename must include its extension. Audio can also be requested by the TouchOSC/operator controls, using the same active-language path. 

## Visual loading

Timeline visuals are loaded separately from being shown. This permits a sequence to prepare a visual and display it at a later timestamp:

The current `VisualPlayer` resolves visuals by file extension:

| Extension | Directory | Runtime behavior |
| --- | --- | --- |
| `.png` | `Content/Image/` | Reads bytes, creates a `Texture2D`, and displays it as a `Sprite`. |
| `.mp4` | `Content/Video/` | Sets the `VideoPlayer.url` to the file path and plays the video. |

## Static UI assets

Static assets are loaded directly from the content package during scene initialization rather than being embedded in the Unity scene.

### Images

`Content/Image/` contains PNG assets used by the UI and language selection, including:

- `flag_<language-code>.png` — language button graphics and language discovery markers
- `panel_background.png` — instruction panel background
- `start_button_off.png` and `start_button_on.png` — confirmation button graphics

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

The font color loader trims the file contents and applies the parsed color to the target TextMeshPro component. 

