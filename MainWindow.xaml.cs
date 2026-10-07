using System;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;

namespace RelayCtlWPF
{
    public partial class MainWindow : Window
    {
        private readonly RelayController controller;
        private readonly ObservableCollection<RelayDevice> devices;

        public MainWindow()
        {
            InitializeComponent();
            controller = new RelayController();
            devices = new ObservableCollection<RelayDevice>();
            lbBoards.ItemsSource = devices;
            Loaded += MainWindow_Loaded;
        }

        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            EnumerateDevices();
        }

        private void EnumerateDevices()
        {
            foreach (var device in devices)
            {
                controller.CloseDevice(device);
            }
            devices.Clear();
            Log.Clear();

            Log.AppendText($"-- {DateTime.Now:yyyy-MM-dd HH:mm:ss} --\n");

            var foundDevices = controller.EnumerateDevices();
            foreach (var device in foundDevices)
            {
                string displayText = !string.IsNullOrEmpty(device.ProductName)
                    ? device.ProductName
                    : $"VID={device.VendorID:X4}, PID={device.ProductID:X4}";

                Log.AppendText(displayText + "\n");
                devices.Add(device);
            }

            if (devices.Count == 0)
            {
                Log.AppendText("No relay boards present\n");
            }
            else
            {
                lbBoards.SelectedIndex = devices.Count - 1;
            }
        }

        private RelayDevice? GetSelectedDevice()
        {
            if (lbBoards.SelectedIndex >= 0 && lbBoards.SelectedIndex < devices.Count)
            {
                return devices[lbBoards.SelectedIndex];
            }
            return null;
        }

        private void AllButton_Click(object sender, RoutedEventArgs e)
        {
            if (sender is not Button button || button.Tag == null)
                return;

            var device = GetSelectedDevice();
            if (device == null)
                return;

            if (!int.TryParse(button.Tag.ToString() ?? "", out int tag))
                return;

            byte mode = tag switch
            {
                1 => 0xFF,  // ON
                2 => 0xFD,  // OFF
                3 => 0xFE,  // ALL ON
                4 => 0xFC,  // ALL OFF
                _ => 0
            };

            if (!byte.TryParse(seRelNo.Text ?? "1", out byte relay))
                relay = 1;

            string result = controller.SendCommand(device, relay, mode);
            Log.AppendText(result + "\n");
            Log.ScrollToEnd();
        }

        private void ChannelButton_Click(object sender, RoutedEventArgs e)
        {
            if (sender is not Button button || button.Tag == null)
                return;

            var device = GetSelectedDevice();
            if (device == null)
                return;

            if (!int.TryParse(button.Tag.ToString() ?? "", out int tag))
                return;

            byte channel = (byte)(((tag - 1) >> 1) + 1);
            byte mode = ((tag & 1) == 1) ? (byte)0xFF : (byte)0xFD;

            string result = controller.SendCommand(device, channel, mode);
            Log.AppendText(result + "\n");
            Log.ScrollToEnd();
        }

        private void PC_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (PC.SelectedIndex == 1)
            {
                UpdateButtonStatus();
            }
        }

        private void UpdateButtonStatus()
        {
            var device = GetSelectedDevice();
            if (device == null)
                return;

            byte status = controller.GetButtonStatus(device);

            Button[] buttons = new Button[]
            {
                sb1On, sb1Off, sb2On, sb2Off, sb3On, sb3Off, sb4On, sb4Off,
                sb5On, sb5Off, sb6On, sb6Off, sb7On, sb7Off, sb8On, sb8Off
            };

            for (int i = 0; i < 8; i++)
            {
                bool isOn = (status & (1 << i)) != 0;
                buttons[i * 2].Background = isOn ? System.Windows.Media.Brushes.LightGreen : System.Windows.Media.Brushes.LightGray;
                buttons[i * 2 + 1].Background = !isOn ? System.Windows.Media.Brushes.LightCoral : System.Windows.Media.Brushes.LightGray;
            }
        }

    }
}
