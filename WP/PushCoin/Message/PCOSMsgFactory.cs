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
using System.Text;

namespace PushCoin.Message
{
    public class PCOSMsgFactory
    {
        static public PCOSMessageBase Parse(ArraySegment<byte> raw)
        {
            string messageid = Encoding.UTF8.GetString(raw.Array, raw.Offset + PCOSHeader.IDXMessageID, PCOSHeader.SZMessageID);

            switch (messageid)
            {
                case PCOS.MsgPong:
                    PCOSMsgPong pong = PCOSMsgPong.Parse(raw);
                    return pong;

                case PCOS.MsgRegisterAck:
                    PCOSMsgRegisterAck regack = PCOSMsgRegisterAck.Parse(raw);
                    return regack;

                case PCOS.MsgError:
                    PCOSMsgError error = PCOSMsgError.Parse(raw);
                    return error;

                default:
                    break;
            }

            return new PCOSMsgInvalid();
        }
    }
}
