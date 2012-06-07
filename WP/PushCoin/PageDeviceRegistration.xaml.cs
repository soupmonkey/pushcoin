using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;

using PushCoin.Helper;

namespace PushCoin
{
    public partial class PageDeviceRegistration : PhoneApplicationPage
    {
        static private string DeRegisterLabel = "de-register";
        static private string RegisterLabel = "register";

        private DSAHelper dsahelper;
        private volatile bool bRegisteringInProgress = false;
        private bool bDeviceRegistered = false;

        public PageDeviceRegistration()
        {
            InitializeComponent();
        }

        #region input_mgmt
        private int prvpos = 0;
        private void tbRegisterID_TextChanged(object sender, TextChangedEventArgs e)
        {
            int cursorLocation = tbRegisterID.SelectionStart;
            tbRegisterID.Text = tbRegisterID.Text.ToUpper();
            tbRegisterID.SelectionStart = cursorLocation;

            if(prvpos < cursorLocation) // move forward
            {
                if(this.tbRegisterID.Text.Length == 4) // at 4th pos, we append a "-"
                {
                    this.tbRegisterID.Text += "-";
                    this.tbRegisterID.SelectionStart = tbRegisterID.Text.Length;
                }
            }
            prvpos = cursorLocation;
        }
        private void tbRegisterID_KeyUp(object sender, KeyEventArgs e)
        {
            if(e.Key == Key.Enter)
                RegistringWithServer();
        }
        private bool ValidateRegisterID()
        {
            if (this.tbRegisterID.Text.Length < 9)
            {
                this.tbRegisterStatus.Text = "please enter full 8 characters code";
                return false;
            }
            int pos = 0;
            foreach (char achar in this.tbRegisterID.Text)
            {
                if ((achar >= 'A' && achar <= 'Z') ||
                    (achar >= '0' && achar <= '9') ||
                    (achar == '-'))
                {
                    pos++;
                }
                else
                    break;
            }
            if (pos < this.tbRegisterID.Text.Length)
            {
                this.tbRegisterID.Select(pos, 1);
                this.tbRegisterStatus.Text = "invalid character code:" + this.tbRegisterID.Text[pos];
                return false;
            }

            return true;
        }
        private void RegistringWithServer()
        {
            if (ValidateRegisterID() && bRegisteringInProgress == false)
            {
                bRegisteringInProgress = true;

                this.tbRegisterStatus.Text = "please do NOT leave this screen while we are registering with Push Coin server...";

                dsahelper = new DSAHelper(this.tbRegisterID.Text);
                dsahelper.OnRegistered += new DSAHelper.OnRegisteredEvent(onRegistrationResult);
                dsahelper.RegisterWithPushCoinServer();
            }
        }
        #endregion

        private void DeviceRegistered()
        {
            this.tbRegisterID.Visibility = System.Windows.Visibility.Collapsed;
            this.btnRegister.Content = DeRegisterLabel;
        }
        private void DeviceUnRegistered()
        {
            this.tbRegisterID.Visibility = System.Windows.Visibility.Visible;
            this.tbRegisterID.Focus();

            this.btnRegister.Content = RegisterLabel;
        }

        private void btnRegister_Click(object sender, RoutedEventArgs e)
        {
            string textlabel = (string) this.btnRegister.Content;
            if (textlabel == DeRegisterLabel)
            {
                MessageBoxResult m = MessageBox.Show("are you sure to De-Register", "de-registration", MessageBoxButton.OKCancel);
                if (m == MessageBoxResult.OK)
                {
                    PCSettings.PEMPublic = String.Empty;
                    PCSettings.PEMPrivate = String.Empty;
                    PCSettings.MAT = String.Empty;
                    PCSettings.Registered = false;

                    DeviceUnRegistered();
                    this.tbRegisterStatus.Text = "your device is un-registered";
                }
            }
            else
            {
                RegistringWithServer();
            }
        }
        private void ContentPanel_Loaded(object sender, RoutedEventArgs e)
        {
            bDeviceRegistered = PCSettings.Registered;

            if (bDeviceRegistered)
            {
                DeviceRegistered();
                this.tbRegisterStatus.Text = "this device already registered on " + PCSettings.RegDatetime;

            }
            else
            {
                DeviceUnRegistered();
                this.tbRegisterStatus.Text = "Enter the 8-character Registration ID as shown on the registration page";
            }
        }

        #region onregistration_event
        void onRegistrationResult(DSAHelper.RegisterResult result)
        {
            Dispatcher.BeginInvoke(() =>
            {
                bRegisteringInProgress = false;

                this.tbRegisterStatus.Text = result.Message;

                bDeviceRegistered = PCSettings.Registered;

                if (bDeviceRegistered)
                    DeviceRegistered();
                else
                    DeviceUnRegistered();
            });
        }
        #endregion

    }
}