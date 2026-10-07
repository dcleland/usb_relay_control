using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace RelayCtlWPF
{
    public class RelayDevice
    {
        public string? ProductName { get; set; }
        public ushort VendorID { get; set; }
        public ushort ProductID { get; set; }
        public IntPtr Handle { get; set; }
        public string? Path { get; set; }
    }

    public class RelayController
    {
        private const string DEVICE_NAME = "USBRelay";
        private const byte CMD_ON = 0xFF;
        private const byte CMD_OFF = 0xFD;
        private const byte CMD_ALL_ON = 0xFE;
        private const byte CMD_ALL_OFF = 0xFC;

        // P/Invoke declarations for Windows HID API
        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern IntPtr SetupDiGetClassDevs(ref Guid interfaceGuid, string? enumerator, IntPtr hwndParent, uint flags);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiEnumDeviceInterfaces(IntPtr hDevInfo, IntPtr devInfo, ref Guid interfaceGuid, uint memberIndex, ref SP_DEVICE_INTERFACE_DATA deviceInterfaceData);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiGetDeviceInterfaceDetail(IntPtr hDevInfo, ref SP_DEVICE_INTERFACE_DATA deviceInterfaceData, ref SP_DEVICE_INTERFACE_DETAIL_DATA deviceInterfaceDetailData, uint deviceInterfaceDetailDataSize, out uint requiredSize, IntPtr deviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiDestroyDeviceInfoList(IntPtr hDevInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess, uint dwShareMode, IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes, IntPtr hTemplateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hObject);

        [DllImport("hid.dll", SetLastError = true)]
        private static extern void HidD_GetHidGuid(out Guid gHid);

        [DllImport("hid.dll", SetLastError = true)]
        private static extern bool HidD_GetProductString(IntPtr hDevice, StringBuilder buffer, uint bufferLength);

        [DllImport("hid.dll", SetLastError = true)]
        private static extern bool HidD_SetFeature(IntPtr hDevice, byte[] reportBuffer, uint reportBufferLength);

        [DllImport("hid.dll", SetLastError = true)]
        private static extern bool HidD_GetFeature(IntPtr hDevice, byte[] reportBuffer, uint reportBufferLength);

        [DllImport("hid.dll", SetLastError = true)]
        private static extern bool HidD_GetAttributes(IntPtr hDevice, out HID_ATTRIBUTES attributes);

        [StructLayout(LayoutKind.Sequential)]
        private struct SP_DEVICE_INTERFACE_DATA
        {
            public uint cbSize;
            public Guid InterfaceClassGuid;
            public uint Flags;
            public IntPtr Reserved;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        private struct SP_DEVICE_INTERFACE_DETAIL_DATA
        {
            public uint cbSize;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string DevicePath;
        }

        private struct HID_ATTRIBUTES
        {
            public uint Size;
            public ushort VendorID;
            public ushort ProductID;
            public ushort VersionNumber;
        }

        private const uint DIGCF_PRESENT = 0x00000002;
        private const uint DIGCF_DEVICEINTERFACE = 0x00000010;
        private const uint FILE_GENERIC_READ = 0x120089;
        private const uint FILE_GENERIC_WRITE = 0x120116;
        private const uint FILE_SHARE_READ = 0x00000001;
        private const uint FILE_SHARE_WRITE = 0x00000002;
        private const uint OPEN_EXISTING = 0x00000003;
        private const uint FILE_FLAG_OVERLAPPED = 0x40000000;

        public List<RelayDevice> EnumerateDevices()
        {
            var devices = new List<RelayDevice>();
            HidD_GetHidGuid(out Guid gHid);

            IntPtr hDevInfo = SetupDiGetClassDevs(ref gHid, null, IntPtr.Zero, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
            if (hDevInfo == IntPtr.Zero || hDevInfo == new IntPtr(-1))
                return devices;

            try
            {
                SP_DEVICE_INTERFACE_DATA deviceInterfaceData = new SP_DEVICE_INTERFACE_DATA();
                deviceInterfaceData.cbSize = (uint)Marshal.SizeOf(deviceInterfaceData);

                for (uint i = 0; SetupDiEnumDeviceInterfaces(hDevInfo, IntPtr.Zero, ref gHid, i, ref deviceInterfaceData); i++)
                {
                    SP_DEVICE_INTERFACE_DETAIL_DATA deviceInterfaceDetailData = new SP_DEVICE_INTERFACE_DETAIL_DATA();
                    deviceInterfaceDetailData.cbSize = (uint)Marshal.SizeOf(deviceInterfaceDetailData);

                    uint requiredSize = 0;
                    if (!SetupDiGetDeviceInterfaceDetail(hDevInfo, ref deviceInterfaceData, ref deviceInterfaceDetailData, (uint)Marshal.SizeOf(deviceInterfaceDetailData), out requiredSize, IntPtr.Zero))
                        continue;

                    string? devicePath = deviceInterfaceDetailData.DevicePath?.TrimEnd('\0');
                    if (string.IsNullOrEmpty(devicePath))
                        continue;

                    IntPtr hDevice = CreateFile(devicePath, FILE_GENERIC_READ | FILE_GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, IntPtr.Zero, OPEN_EXISTING, 0, IntPtr.Zero);
                    if (hDevice == IntPtr.Zero || hDevice == new IntPtr(-1))
                        continue;

                    try
                    {
                        var device = new RelayDevice
                        {
                            Path = devicePath,
                            Handle = hDevice
                        };

                        // Get product name
                        StringBuilder productName = new StringBuilder(256);
                        if (HidD_GetProductString(hDevice, productName, 256))
                        {
                            device.ProductName = productName.ToString();
                        }

                        // Get attributes
                        HID_ATTRIBUTES attributes = new HID_ATTRIBUTES();
                        attributes.Size = (uint)Marshal.SizeOf(attributes);
                        if (HidD_GetAttributes(hDevice, out attributes))
                        {
                            device.VendorID = attributes.VendorID;
                            device.ProductID = attributes.ProductID;
                        }

                        // Filter for USBRelay devices
                        if (!string.IsNullOrEmpty(device.ProductName) && device.ProductName.StartsWith(DEVICE_NAME))
                        {
                            devices.Add(device);
                        }
                        else
                        {
                            CloseHandle(hDevice);
                        }
                    }
                    catch
                    {
                        CloseHandle(hDevice);
                    }
                }
            }
            finally
            {
                SetupDiDestroyDeviceInfoList(hDevInfo);
            }

            return devices;
        }

        public string SendCommand(RelayDevice device, byte relay, byte mode)
        {
            if (device.Handle == IntPtr.Zero)
                return "Device not open";

            byte[] reportBuffer = new byte[10];
            reportBuffer[0] = 0;
            reportBuffer[1] = mode;
            reportBuffer[2] = relay;

            try
            {
                if (!HidD_SetFeature(device.Handle, reportBuffer, 9))
                    return "Command not sent";

                string result = $"{reportBuffer[0]:X2} {reportBuffer[1]:X2} {reportBuffer[2]:X2}";

                if (HidD_GetFeature(device.Handle, reportBuffer, 9))
                {
                    result += $" - {reportBuffer[8]:X2}";
                }

                return result;
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        public byte GetButtonStatus(RelayDevice device)
        {
            if (device.Handle == IntPtr.Zero)
                return 0;

            byte[] reportBuffer = new byte[10];
            reportBuffer[0] = 0;
            reportBuffer[1] = 0;
            reportBuffer[2] = 0;

            try
            {
                if (HidD_GetFeature(device.Handle, reportBuffer, 9))
                {
                    return reportBuffer[8];
                }
            }
            catch { }

            return 0;
        }

        public void CloseDevice(RelayDevice device)
        {
            if (device.Handle != IntPtr.Zero)
            {
                CloseHandle(device.Handle);
                device.Handle = IntPtr.Zero;
            }
        }
    }
}
