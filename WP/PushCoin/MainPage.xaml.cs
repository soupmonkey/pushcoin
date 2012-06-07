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
using PushCoin.Message;

namespace PushCoin
{
    public partial class MainPage : PhoneApplicationPage
    {
        // Constructor
        public MainPage()
        {
            InitializeComponent();

            // Set the data context of the listbox control to the sample data
            DataContext = App.ViewModel;
            this.Loaded += new RoutedEventHandler(MainPage_Loaded);
        }

        // Load data for the ViewModel Items
        private void MainPage_Loaded(object sender, RoutedEventArgs e)
        {
            if (!App.ViewModel.IsDataLoaded)
            {
                App.ViewModel.LoadData();
            }

            if (PCSettings.Registered == false)
            {
                //btnRegister_Click(this, new RoutedEventArgs());
            }
        }

        private PingHelper ping = null;
        private void pingme_DoubleTap(object sender, GestureEventArgs e)
        {
            ping = new PingHelper();
            ping.PingPongResponse += new PingHelper.PingPongResponseHandler(ping_PingPongResponse);
            ping.PingPushCoinServer();
            this.pong.Text = "... contacting PC";
        }
        public void ping_PingPongResponse(object sender, PingPongEventArgs ppea)  
        {
            Deployment.Current.Dispatcher.BeginInvoke(() =>
            {
                if (ppea.Message is PCOSMsgPong)
                {
                    PCOSMsgPong pong = (PCOSMsgPong)ppea.Message;
                    this.pong.Text = pong.PongTime.ToString();
                }
            });

        }

        private void btnRegister_Click(object sender, RoutedEventArgs e)
        {
            this.NavigationService.Navigate(new Uri("/PageDeviceRegistration.xaml", UriKind.Relative));

            //Register reg = new Register();
        }
    }
}