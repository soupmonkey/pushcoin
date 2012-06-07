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
    public class PCOSHeader
    {
        #region data
        public const int SIZE = 18;

        public const int IDXMagic = 0;
        public const int SZMagic = 4;

        public const int IDXMessageLength = 4;
        public const int SZMessageLength = sizeof(Int32);

        public const int IDXMessageID = 8;
        public const int SZMessageID = 2;

        public const int IDXReserved = 10;
        public const int SZReserved = 6;

        public const int IDXMessageBlockCount = 16;
        public const int SZMessageBlockCount = sizeof(Int16);

        // header
        protected string Magic = PCOS.Magic;               // 4 chars
        protected Int32 MessageLength = PCOSHeader.SIZE;   // int32
        public string MessageID = PCOS.MsgINVALID;      // 2 chars
        private const string Reserved = "      ";       // 6 chars, reserved

        // message block count
        protected Int16 MessageBlockCount = 0;             // int16       

        private bool _validmsg = true;
        protected bool ValidMesssage { get { return _validmsg; } set { _validmsg = value; } }

        #endregion

        public PCOSHeader(string id)
        {
            MessageID = id;
        }
        public override string ToString()
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("Magic=");
            sb.Append(Magic);
            sb.Append(", MessageLength=");
            sb.Append(MessageLength);
            sb.Append(", MessageID=");
            sb.Append(MessageID);
            sb.Append(", Reserved=");
            sb.Append(Reserved);
            sb.Append(", BlockCount=");
            sb.Append(MessageBlockCount);
            sb.Append("|");

            return sb.ToString();
        }
        public virtual byte[] Bytes
        {
            get
            {
                byte[] headerbytes = new Byte[SIZE];

                System.Text.Encoding.UTF8.GetBytes(Magic, 0, SZMagic, headerbytes, IDXMagic);
                Buffer.BlockCopy(BitConverter.GetBytes(MessageLength), 0, headerbytes, IDXMessageLength, SZMessageLength);
                System.Text.Encoding.UTF8.GetBytes(MessageID, 0, SZMessageID, headerbytes, IDXMessageID);
                System.Text.Encoding.UTF8.GetBytes(Reserved, 0, SZReserved, headerbytes, IDXReserved);
                Buffer.BlockCopy(BitConverter.GetBytes(MessageBlockCount), 0, headerbytes, IDXMessageBlockCount, SZMessageBlockCount);

                return headerbytes;
            }
        }
        protected void ParseHeader(ArraySegment<byte> raw)
        {
            Magic = System.Text.Encoding.UTF8.GetString(raw.Array, raw.Offset + IDXMagic, SZMagic);
            MessageLength = BitConverter.ToInt32(raw.Array, raw.Offset + IDXMessageLength);
            MessageID = System.Text.Encoding.UTF8.GetString(raw.Array, raw.Offset + IDXMessageID, SZMessageID);
            MessageBlockCount = BitConverter.ToInt16(raw.Array, raw.Offset + IDXMessageBlockCount);
        }
    }
}
