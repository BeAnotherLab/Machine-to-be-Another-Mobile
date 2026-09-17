# JSON Sequencer Specification

This document describes the JSON timeline format used to drive guided interaction sequences in **The Machine to Be Another (Mobile)**.

The sequencer reads a JSON file containing an ordered list of timed steps. Each step can update localized instructions, play audio, load a visual asset, and invoke one or more runtime actions.

## Related files

- Runtime sequence: [`Content/Config/sequence.json`](../Content/Config/sequence.json)
- Automatic sequence template: [`Content/Template/technorama_auto_sequence.json`](../Content/Template/technorama_auto_sequence.json)
- Step model: [`Assets/Scripts/JSONSequencing/SequenceStep.cs`](../Assets/Scripts/JSONSequencing/SequenceStep.cs)
- Sequence runner: [`Assets/Scripts/JSONSequencing/JsonSequenceController.cs`](../Assets/Scripts/JSONSequencing/JsonSequenceController.cs)

## File format

A sequence is a JSON object with a required `steps` array:

```json
{
  "steps": [
    {
      "time": 0.0,
      "textKey": "welcome",
      "audio": "welcome.ogg",
      "actions": ["WallOn"]
    }
  ]
}
```

The file is loaded from `Content/Config/sequence.json`. Content is copied to the headset with `copy-content.sh` as part of the normal installation process.

### Strict JSON

Sequence files must contain valid JSON. In particular:

- Do not add trailing commas after the final property in an object or array.
- Property names and string values must use double quotes.
- `steps` must contain at least one step for the sequence to run.

## Sequence steps

Each item in `steps` has the following properties:

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `time` | number | Yes | Time in seconds from the beginning of the sequence. |
| `textKey` | string | No | Key looked up in the active translation file. Updates the instruction panel when the step runs. |
| `audio` | string | No | Audio filename to play. The file is resolved from the content/audio localization structure. |
| `visual` | string | No | Image or video filename to load. `.png` and `.mp4` assets are supported by the visual player. |
| `actions` | array of strings | No | Actions to execute in the listed order. |

A step may contain any combination of optional properties, including only an `actions` array:

```json
{
  "time": 26.0,
  "actions": ["HidePanel", "HideVisual"]
}
```

## Timing rules

- `time` is measured in seconds from sequence start.
- Steps are processed in array order.
- The controller converts each absolute `time` into a delay from the previous step.
- Keep steps in ascending time order. A step with an earlier time than the preceding step produces a negative interval and is not a supported sequence definition.
- Multiple steps may use the same time when their callbacks should occur together. Their order in the array determines execution order.
- A step does not automatically hide or stop an asset. Add an explicit action such as `HideVisual` or `HidePanel` when needed.

## Text and localization

`textKey` is a translation key, not the text displayed to the participant. The key is resolved using the currently selected language under `Content/Translation`.

Example:

```json
{
  "time": 4.9,
  "textKey": "position"
}
```

Add the matching key to each language's translation file before using it in a sequence. If a key is missing, the application logs a warning and cannot display the localized instruction.

## Audio

Use `audio` for a filename, including its extension:

```json
{
  "time": 75.0,
  "audio": "strokeHands.ogg"
}
```

Audio is played when the step executes. A later audio step can start another clip; use the application's stop/reset behavior when a sequence needs to end or be interrupted.

## Visuals

Use `visual` to load an image or video before displaying it:

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

Supported file extensions are:

- `.mp4` for video content
- `.png` for image content

Loading and showing are separate operations, so a sequence can load the visual in one step and show it later. Use `HideVisual` to hide the visual and stop video playback.

## Actions

Actions are executed from left to right in the order listed in `actions`.

| Action | Effect |
| --- | --- |
| `ShowPanel` | Shows the instruction panel. |
| `HidePanel` | Hides the instruction panel. |
| `ShowVisual` | Shows the currently loaded image or video. |
| `HideVisual` | Hides the visual and stops video playback. |
| `StartExperience` | Starts the experience state and undims the experience. |
| `EndExperience` | Ends the experience state and dims the experience. |
| `WallOn` | Closes/turns on the physical or simulated wall curtain. |
| `WallOff` | Opens/turns off the wall curtain. |
| `MirrorOn` | Sends the mirror-on command to the hardware. |
| `MirrorOff` | Sends the mirror-off command to the hardware. |

Example combining several actions:

```json
{
  "time": 165.0,
  "audio": "mirror.ogg",
  "actions": ["MirrorOn"]
}
```

Unknown action names are ignored by the runtime. Prefer the action names in the table above so sequences behave consistently.

## Complete example

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
      "time": 4.9,
      "textKey": "position"
    },
    {
      "time": 15.0,
      "visual": "instructions.mp4"
    },
    {
      "time": 15.1,
      "textKey": "blank",
      "actions": ["ShowVisual"]
    },
    {
      "time": 26.0,
      "actions": ["StartExperience", "HidePanel", "HideVisual"]
    },
    {
      "time": 165.0,
      "audio": "mirror.ogg",
      "actions": ["MirrorOn"]
    },
    {
      "time": 193.0,
      "actions": ["WallOff", "MirrorOff"]
    },
    {
      "time": 230.0,
      "actions": ["EndExperience"]
    }
  ]
}
```

## Authoring checklist

1. Start with a root object containing `steps`.
2. Give every step an absolute `time` in seconds.
3. Keep steps ordered by increasing time.
4. Confirm every `textKey` exists in the translation files.
5. Confirm every audio, image, and video filename exists in the packaged `Content` directory.
6. Use only the supported action names.
7. Validate the file as strict JSON before deploying it to a headset.
8. Test the sequence on the target Quest hardware, especially visual loading and audio timing.

For the broader project setup, see the [main README](../README.md).
