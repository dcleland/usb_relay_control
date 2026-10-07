# Delphi to C# WPF Conversion

This folder contains a C# WPF (Windows Presentation Foundation) conversion of the original Delphi RelayCtl application.

## Files Included

- **App.xaml** - Application definition
- **App.xaml.cs** - Application code-behind
- **MainWindow.xaml** - UI definition (replaces the .dfm file)
- **MainWindow.xaml.cs** - Main window code-behind logic
- **RelayController.cs** - USB HID communication logic
- **RelayCtlWPF.csproj** - Project file for building with .NET 10

## Key Changes from Delphi

### UI Framework
- **Delphi VCL** → **WPF** - Modern Microsoft UI framework
- Form layout defined in XAML instead of .dfm files
- Event handling in C# instead of Object Pascal

### Component Mapping
| Delphi | WPF |
|--------|-----|
| TPanel | StackPanel / Border |
| TButton / TSpeedButton | Button |
| TMemo | TextBox |
| TListBox | ListBox |
| TPageControl / TTabSheet | TabControl / TabItem |
| TSpinEdit | TextBox (with numeric validation) |
| TLabel | TextBlock |

### USB HID Communication
- **Original**: Used `JvHidDeviceController` component from JEDI VCL
- **New**: Uses Windows HID API through P/Invoke
  - `setupapi.dll` - Device enumeration
  - `hid.dll` - HID feature reports
  - Direct Windows API calls for better control

## Building the Project

### Prerequisites
- Visual Studio 2022 (version 17.10 or later), or
- .NET 10 SDK
- Windows 10/11

### Build Steps

1. Open a command prompt in this directory
2. Run:
   ```bash
   dotnet build RelayCtlWPF.csproj
   ```

3. Run the application:
   ```bash
   dotnet run
   ```

Or open the `.csproj` file in Visual Studio and build from there.

## Features

### Left Panel
- Lists all detected USB Relay boards
- Shows product name and identification
- Click to select which board to control

### Right Panel - Two Tabs

#### "Button per Channel" Tab
- Individual ON/OFF buttons for each of 8 relay channels
- Buttons show current relay state
- Mutually exclusive buttons within each channel group

#### "On/Off" Tab
- **ALL ON** - Turns all relays on simultaneously
- **ALL OFF** - Turns all relays off simultaneously
- **ON / OFF** - Controls individual relay with selectable relay number
- Relay Number field (1-8) for single relay control

### Log
- Real-time log of device detection and commands sent
- Shows command bytes in hex format
- Displays device status responses

## API Comparison

### Device Enumeration
**Delphi:**
```pascal
HidCtl.Enumerate;
```

**C#:**
```csharp
var devices = controller.EnumerateDevices();
```

### Sending Commands
**Delphi:**
```pascal
Status := Dev.SetFeature(pB^, 9);
```

**C#:**
```csharp
HidD_SetFeature(device.Handle, reportBuffer, 9);
```

### Getting Feature Reports
**Delphi:**
```pascal
Status := Dev.GetFeature(pB^, 9);
```

**C#:**
```csharp
HidD_GetFeature(device.Handle, reportBuffer, 9);
```

## Architecture

### RelayController Class
Handles all USB HID communication:
- `EnumerateDevices()` - Finds and opens USB relay boards
- `SendCommand()` - Sends on/off commands
- `GetButtonStatus()` - Reads current relay states
- `CloseDevice()` - Properly closes device handles

### MainWindow Class
Manages UI and event handling:
- Device enumeration on startup
- Button click event handlers
- Log text display
- Button state synchronization

## Communication Protocol

The application communicates with USB relay boards using HID feature reports:

| Byte | Purpose | Values |
|------|---------|--------|
| 0 | Report ID | 0x00 |
| 1 | Command | 0xFF (ON), 0xFD (OFF), 0xFE (ALL ON), 0xFC (ALL OFF) |
| 2 | Relay Number | 1-8 for individual, 0 for all |
| 8 | Status Response | Bit mask of relay states |

## Known Differences from Delphi Version

1. **UI Appearance**: WPF has a slightly more modern look but same layout
2. **Device Enumeration**: Automatic at startup; no explicit enumerate button
3. **Button Styling**: WPF buttons instead of VCL SpeedButtons
4. **Target Framework**: .NET 10 (latest LTS release)

## Troubleshooting

### No devices detected
- Ensure USB relay boards are connected
- Check Device Manager for USB devices
- Verify driver is installed

### Command fails
- Check log for error messages
- Ensure board is properly selected in the list
- Verify relay number is 1-8

### Build errors
- Ensure .NET 10 SDK is installed: `dotnet --version`
- Check Visual Studio is up to date (17.10 or later)
- Delete bin/obj folders and rebuild

## Future Enhancements

Possible improvements from Delphi version:
- Add device reconnection handling
- Implement command queuing
- Add timing controls for relay states
- Profile/preset management
- MVVM architecture for better testability

## License

Converted from original Delphi application.
