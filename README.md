# Kountdown

Kountdown is a KDE Plasma 6 countdown widget for tracking a duration or a
specific date and time.

## Features

- Duration or date/time countdowns
- Custom timer names
- Compact panel representation and expanded popup view
- Optional seconds in the panel
- Desktop notification when a timer finishes
- Optional configurable completion sound
- Context-menu actions for starting, stopping, restarting, and copying the
  remaining time
- Quick target adjustment by one hour or one minute

## Requirements

- KDE Plasma 6
- `kpackagetool6` to install the widget
- `plasmoidviewer` for development previews

## Installation

From the repository directory:

```bash
kpackagetool6 --type Plasma/Applet --install package
```

Add **Kountdown** to a panel or the desktop using Plasma's widget chooser.

To update an existing installation after changing the source:

```bash
./upgrade.sh
```

The upgrade script installs the package and restarts Plasma Shell when its
user service is available.

## Development

Run both the horizontal panel preview and the expanded preview:

```bash
./preview.sh
```

Stop both preview windows with `Ctrl+C`.

## Configuration

Open the widget settings to configure:

- Countdown type, target, and duration
- Timer name
- Whether seconds are shown in the panel
- Completion notifications
- Completion sound and sound file path

The default completion sound is:

```text
/usr/share/sounds/ocean/stereo/alarm-clock-elapsed.oga
```

## License

GPL-3.0-or-later
