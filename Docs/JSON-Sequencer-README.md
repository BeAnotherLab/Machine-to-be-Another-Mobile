# JSON Sequencer Specification

This document describes the JSON timeline format used to drive guided interaction sequences in **The Machine to Be Another (Mobile)**.

The sequencer reads a JSON file containing an ordered list of timed steps. Each step can update localized instructions, play audio, load a visual asset, and invoke one or more runtime actions.

The sequencer was initially built for a fully automated swap experience at the Technorama Science Center. It is also integrated in settings where assistants are facilitating the experience, where the sequencer is used to display instructions automatically before the experience is manually started.

## Related files

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
- Multiple steps may use the same time when their callbacks should occur together. Their order in the array determines execution order.

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

Unknown action names are ignored by the runtime. Prefer the action names in the table above so sequences behave consistently.

## Examples
- Default sequence: [`Content/Config/sequence.json`](../Content/Config/sequence.json). This sequence shows instructions and lets assistants turn the screen on with the Touch OSC app and control the flow of the experience.
- Automatic sequence template: [`Content/Template/technorama_auto_sequence.json`](../Content/Template/technorama_auto_sequence.json)


For the broader project setup, see the [main README](../README.md).
