using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;

namespace PushCoin.Message
{
    public class PCOS
    {
        public const string Magic = "PCOS";
        public const string UserAgent = "wp.pushcoin";

        public const string MsgINVALID = "  ";

        public const string MsgError = "Er";
        public const string MsgPing = "Pi";
        public const string MsgPong = "Po";
        public const string MsgRegister = "Re";
        public const string MsgRegisterAck = "Ac";
    }
}
