using System;
using System.IO;
using System.Windows;

namespace RelayCtlWPF
{
    public partial class App : Application
    {
        public App()
        {
            DispatcherUnhandledException += App_DispatcherUnhandledException;
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;
        }

        private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
        {
            LogException("DispatcherUnhandledException", e.Exception);
            e.Handled = false;
        }

        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogException("UnhandledException", (Exception)e.ExceptionObject);
        }

        private static void LogException(string source, Exception ex)
        {
            try
            {
                string logPath = Path.Combine(Path.GetTempPath(), "RelayCtlWPF_Error.log");
                string message = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{source}]\n{ex}\n\n";
                File.AppendAllText(logPath, message);
            }
            catch { }
        }
    }
}
