# Window Glue

A simple macOS menu bar utility that lets you glue windows together so that they behave (mostly) as one.

![Window Glue Demo](assets/demo.gif)

## Features

- **Intuitive Window Snapping**: Drag any window near another to see glow indicators and snap them together
- **Smart Positioning**: Windows automatically align to edges with configurable tolerance
- **Shake to Unglue**: Quickly shake any window to disconnect it
- **Keyboard Shortcuts**: Customizable hotkeys for toggling glue mode and unglueing windows
- **Menu Bar Integration**: Easy access to all features from the menu bar
- **Launch at Startup**: Optional auto-launch with system startup

## Installation

### Download Release
1. Download the latest release from [Releases](https://github.com/Conxt/window-glue/releases)
2. Mount and drag Window Glue.app to your Applications folder
3. Launch and grant Accessibility permissions when prompted

### Build from Source
1. Clone this repository
2. Open `Window Glue.xcodeproj` in Xcode 15+
3. Build and run (requires macOS 13.0+)

## Usage

1. Click the Window Glue icon in your menu bar
2. Toggle "Add Glue" to enable window snapping mode
3. Drag any window near another window
4. Watch for the glow indicator showing snap positions
5. The dragged window will snap to the terget window
6. Shake a window quickly to unglue its connection

### Keyboard Shortcuts
- **F9**: Toggle glue mode on/off
- **Shift+F9**: Unglue active window

Shortcuts can be customized in Settings.

## Requirements

- macOS 13.0 (Sonoma) or later
- Accessibility permissions (granted on first launch)

## Privacy

Window Glue requires Accessibility permissions to monitor and manage window positions. No data is collected or transmitted. All processing happens locally on your device.

## Known Issues

1. When dragging a glued window, there is a bit of a lag for the paired window to catch up.
2. When a glued window is dragged to another screen and/or space, the paired window doesn't (yet) follow automatically. When you drag the second window to the new screen/space manually, they will stick together again.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request (and list yourself as a contributor in Credits).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created by [Andriy Konstantynov](https://github.com/Conxt) in Ukraine 🇺🇦

## Support

- [Report Issues](https://github.com/Conxt/window-glue/issues)
- [Feature Requests](https://github.com/Conxt/window-glue/discussions)
