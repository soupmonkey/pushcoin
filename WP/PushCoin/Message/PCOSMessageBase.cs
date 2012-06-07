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
using System.Collections.Generic;

namespace PushCoin.Message
{
    public class PCOSMessageBase : PCOSHeader
    {
        // message blocks
        protected List<PCOSMessageBlock> MessageBlocks = new List<PCOSMessageBlock>();

        public PCOSMessageBase(string msgid)
            : base(msgid)
        {
        }

        public override byte[] Bytes
        {
            get
            {
                // determine total pcos message length (header + each msgblock size)
                int totalmsglength = PCOSHeader.SIZE;

                foreach (PCOSMessageBlock pcosmsgblock in MessageBlocks)
                    totalmsglength += pcosmsgblock.TotalBlockLength;

                // update total pcos message length to its header
                base.MessageLength = totalmsglength; 

                // allocate enough bytes for this message
                byte[] totalmsgblocksbytes = new byte[totalmsglength];

                // copy header bytes first..
                Buffer.BlockCopy(base.Bytes, 0, totalmsgblocksbytes, 0, PCOSHeader.SIZE);

                // iterate message blocks for all message blocks
                int offset = PCOSHeader.SIZE;
                foreach (PCOSMessageBlock pcosmsgblock in MessageBlocks)
                {
                    Buffer.BlockCopy(pcosmsgblock.Bytes, 0, totalmsgblocksbytes, offset, pcosmsgblock.TotalBlockLength);
                    offset += pcosmsgblock.TotalBlockLength;
                }

                return totalmsgblocksbytes;
            }
        }

        protected bool AddMessageBlock(PCOSMessageBlock msgblock)
        {
            bool good = true;

            MessageBlocks.Add(msgblock);
            base.MessageBlockCount = (short)MessageBlocks.Count;

            return good;
        }

        protected bool ParseMessageBlock(ArraySegment<byte> raw)
        {
            int offset = PCOSHeader.SIZE;

            for (int x = 0; x < base.MessageBlockCount; x++)
            {
                PCOSMessageBlock msgblock = PCOSMessageBlock.Parse(raw, offset);
                MessageBlocks.Add(msgblock);
                offset += msgblock.TotalBlockLength;
            }
            return true;
        }
    }
}
