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
    public class PCOSMsgPing : PCOSMessageBase
    {
        public PCOSMsgPing()
            : base(PCOS.MsgPing)
        {
        }
    }

    public class PCOSMsgPong : PCOSMessageBase
    {

        public PCOSMsgPong()
            : base(PCOS.MsgPong)
        {
        }

        public DateTime PongTime;

        static public PCOSMsgPong Parse(ArraySegment<byte> raw)
        {
            PCOSMsgPong pong = new PCOSMsgPong();

            pong.ParseHeader(raw);
            pong.ParseMessageBlock(raw);

            if (pong.MessageBlocks.Count > 0)
            {
                int offset = pong.MessageBlocks[0].BlockData.Offset;
                Int64 pongtimeraw = BitConverter.ToInt64(pong.MessageBlocks[0].BlockData.Array, offset);
                pong.PongTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
                pong.PongTime = pong.PongTime.AddSeconds(pongtimeraw).ToLocalTime();
            }

            return pong;
        }
        public override string ToString()
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append(base.ToString());
            for (int x = 0; x < MessageBlocks.Count; x++)
                sb.Append(MessageBlocks[x]);
            sb.Append(" PongTime=");
            sb.Append(PongTime);
            return sb.ToString();
        }
    }
}
