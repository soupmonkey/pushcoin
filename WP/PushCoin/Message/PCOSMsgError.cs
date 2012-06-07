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
    public class PCOSMsgError : PCOSMessageBase
    {
        public PCOSMsgError()
            : base(PCOS.MsgError)
        {
        }

        public const int IDXErrorCode = 0;
        public const int SZErrorCode = sizeof(Int32);

        public const int IDXReasonLength = 4;
        public const int SZReasonLength = sizeof(char);

        public const int IDXReason = 5;

        public Int32 ErrorCode = 0;
        private Int32 ReasonLength = 0;
        public String Reason = "";
        public int RefDataLength = 0;

        static public PCOSMsgError Parse(ArraySegment<byte> raw)
        {
            PCOSMsgError errmsg = new PCOSMsgError();

            errmsg.ParseHeader(raw);
            errmsg.ParseMessageBlock(raw);

            if (errmsg.MessageBlocks.Count > 0)
            {
                int offset = errmsg.MessageBlocks[0].BlockData.Offset;

                // 2012.05.27 -- why 2 extra bytes here?
                offset += 2;

                errmsg.ErrorCode = BitConverter.ToInt32(errmsg.MessageBlocks[0].BlockData.Array, offset);

                byte[] cx = new byte[2];
                Buffer.BlockCopy(errmsg.MessageBlocks[0].BlockData.Array, offset + PCOSMsgError.IDXReasonLength, cx, 0, 1);
                errmsg.ReasonLength = (int)cx[0];

                if (errmsg.ReasonLength > 0 && errmsg.ReasonLength < errmsg.MessageBlocks[0].BlockLength)
                {
                    errmsg.Reason = System.Text.Encoding.UTF8.GetString(errmsg.MessageBlocks[0].BlockData.Array, offset + PCOSMsgError.IDXReason, errmsg.ReasonLength);
                }
            }

            return errmsg;
        }

        public override string ToString()
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();

            sb.Append(base.ToString());
            for (int x = 0; x < MessageBlocks.Count; x++) sb.Append(MessageBlocks[x]);
            sb.Append(" ErrorCode=");
            sb.Append(ErrorCode);
            sb.Append(" ReasonLength=");
            sb.Append(ReasonLength);
            sb.Append(" Reason=");
            sb.Append(Reason);

            return sb.ToString();
        }
    }
}
