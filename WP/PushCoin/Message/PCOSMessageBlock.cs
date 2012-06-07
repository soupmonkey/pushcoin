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
    public class PCOSMessageBlock
    {
        private const Int16 MINSIZE = 4; // ID + BlockLength

        public const int IDXBlockID = 0;
        public const int SZBlockID = 2;

        public const int IDXBlockLength = 2;
        public const int SZBlockLength = sizeof(Int16);

        public const int IDXBlockData = 4;

        public string BlockID = "  "; // char[2]
        public Int16 BlockLength = 0;
        public ArraySegment<byte> BlockData;

        public Int16 TotalBlockLength
        {
            get { return (short)(PCOSMessageBlock.MINSIZE + BlockLength); }
        }

        public byte[] Bytes
        {
            get
            {
                byte[] blockbytes = new byte[TotalBlockLength];

                System.Text.Encoding.UTF8.GetBytes(BlockID, 0, SZBlockID, blockbytes, IDXBlockID);
                Buffer.BlockCopy(BitConverter.GetBytes(BlockLength), 0, blockbytes, IDXBlockLength, SZBlockLength);
                Buffer.BlockCopy(BlockData.Array, BlockData.Offset, blockbytes, IDXBlockData, BlockLength);

                return blockbytes;
            }
        }

        public PCOSMessageBlock(string id, byte[] blockdata)
            : this(id, new ArraySegment<byte>(blockdata))
        {
        }

        public PCOSMessageBlock(string id, ArraySegment<byte> blockdata)
        {
            BlockID = id;
            BlockLength = (short)blockdata.Count; // excluding sizeof(ID + BlockLength), only BlockData size
            BlockData = blockdata;
        }

        public override string ToString()
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("BlockID=");
            sb.Append(BlockID);
            sb.Append(", BlockLength=");
            sb.Append(BlockLength);
            sb.Append(" [");
            sb.Append(BitConverter.ToString(BlockData.Array, BlockData.Offset, BlockData.Count));
            sb.Append("]");
            return sb.ToString();
        }
        static public PCOSMessageBlock Parse(ArraySegment<byte> raw, int offset)
        {
            string ID = System.Text.Encoding.UTF8.GetString(raw.Array, offset, SZBlockID);
            Int16 BlockLength = BitConverter.ToInt16(raw.Array, offset + PCOSMessageBlock.SZBlockID);
            ArraySegment<byte> BlockData = new ArraySegment<byte>(raw.Array, offset + PCOSMessageBlock.SZBlockID + PCOSMessageBlock.SZBlockLength, BlockLength);

            return (new PCOSMessageBlock(ID, BlockData));
        }
    }
}
