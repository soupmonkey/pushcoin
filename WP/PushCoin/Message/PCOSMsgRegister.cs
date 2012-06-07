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
    public class PCOSMsgRegister : PCOSMessageBase
    {
        private string _registrationid = "";
        public string RegistrationID
        {
            set { _registrationid = value; }
            get { return _registrationid; }
        }      

        private bool isPEM = true;
        #region PEM
        private static string PEMPK = "MIHwMIGoBgcqhkjOOAQBMIGcAkEAjfeT35NuNNXa9J6WFRGkbLFPbMjTvfBwBmlIBxkn5C7P7tbrSKX2v4kkNOxaSoL1IbAcIsRfLAQONhu5OypILwIVAKPptYe+gRwRHTd47lSliZcv6HXxAkASAkNvUTHAAayp1ozyEa42u/9el+r5ffTGK1VH9VYgCc3dcUHOxGl3gXl2KQfNPt6owQKKsZnrpgO1v1N+ciLWA0MAAkA9jERRrih0tMqrqBq3iRmpqQXFQhsy+oyPST9v+KiP+POtARwoOToKJw8Ub8o3EdjoXWobCvDbxTMPP447uJkT";
        private char mynewline = '\n';
        private static string PEMPKBegin = "-----BEGIN PUBLIC KEY-----";
        private static string PEMPKEnd = "-----END PUBLIC KEY-----";

        private string _pempublickey = "";
        private string PEMPublicKey
        {
            get { return _pempublickey; }
            set { _pempublickey = value; }
        }
        #endregion
        #region DER
        private ArraySegment<byte> _derprivatekey;
        private ArraySegment<byte> DERPrivateKey
        {
            get { return _derprivatekey; }
            set { _derprivatekey = value; }
        }
        private ArraySegment<byte> _derpublickey;
        private ArraySegment<byte> DERPublicKey
        {
            get { return _derpublickey; }
            set { _derpublickey = value; }
        }
        #endregion

        public string UserAgent { get { return PCOS.UserAgent; } }

        public PCOSMsgRegister()
            : base(PCOS.MsgRegister)
        {
        }
        public PCOSMsgRegister(string regid, string pempubkey)
            : base(PCOS.MsgRegister)
        {
            RegistrationID = regid;
            //PEMPublicKey = PCOSMsgRegister.PEMPKBegin + PCOSMsgRegister.PEMPK + PCOSMsgRegister.PEMPKEnd;
            PEMPublicKey = PCOSMsgRegister.PEMPKBegin + this.mynewline + pempubkey + this.mynewline + PCOSMsgRegister.PEMPKEnd;
        }
        public PCOSMsgRegister(string regid, ArraySegment<byte> derpubkey)
            : base(PCOS.MsgRegister)
        {
            RegistrationID = regid;
            DERPublicKey = derpubkey;
            isPEM = false;
        }

        public override byte[] Bytes
        {
            get
            {
                base.MessageBlocks.Clear();
                AddMessageBlock();
                return base.Bytes;
            }
        }
        private void AddMessageBlock()
        {
            int datablocksize = 1 + this.RegistrationID.Length +
                                sizeof(Int16) + (this.isPEM ? this.PEMPublicKey.Length : this.DERPublicKey.Count) +
                                sizeof(Int16) + this.UserAgent.Length;

            byte[] blockdata = new byte[datablocksize];

            int offset = 0;
            blockdata[offset] = (byte) RegistrationID.Length;
            offset += 1;

            System.Text.Encoding.UTF8.GetBytes(this.RegistrationID, 0, this.RegistrationID.Length, blockdata, offset);
            offset += this.RegistrationID.Length;

            if (this.isPEM)
            {
                Int16 pempubkeylength = (Int16)this.PEMPublicKey.Length;
                Buffer.BlockCopy(BitConverter.GetBytes(pempubkeylength), 0, blockdata, offset, sizeof(Int16));
                offset += sizeof(Int16);

                System.Text.Encoding.UTF8.GetBytes(this.PEMPublicKey, 0, this.PEMPublicKey.Length, blockdata, offset);
                offset += this.PEMPublicKey.Length;
            }
            else
            {
                Int16 derpubkeylength = (Int16)this.DERPublicKey.Count;
                Buffer.BlockCopy(BitConverter.GetBytes(derpubkeylength), 0, blockdata, offset, sizeof(Int16));
                offset += sizeof(Int16);

                Buffer.BlockCopy(DERPublicKey.Array, DERPublicKey.Offset, blockdata, offset, DERPublicKey.Count);
                offset += DERPublicKey.Count;
            }

            blockdata[offset] = (byte) this.UserAgent.Length;
            offset += sizeof(Int16);

            System.Text.Encoding.UTF8.GetBytes(this.UserAgent, 0, this.UserAgent.Length, blockdata, offset);

            base.AddMessageBlock(new PCOSMessageBlock("Bo", blockdata));
        }
        static public PCOSMsgRegister Parse(ArraySegment<byte> raw)
        {
            PCOSMsgRegister reg = new PCOSMsgRegister();

            reg.ParseHeader(raw);
            reg.ParseMessageBlock(raw);

            if (reg.MessageBlocks.Count > 0)
            {
            }

            return reg;
        }
    }

    public class PCOSMsgRegisterAck : PCOSMessageBase
    {
        private ArraySegment<byte> iMAT;
        public byte[] MAT 
        { 
            get 
            { 
                byte[] retbytes = new byte[iMAT.Count];
                Buffer.BlockCopy(iMAT.Array, iMAT.Offset, retbytes, 0, iMAT.Count);
                return retbytes;
            } 
        }
        private string strMAT;

        public PCOSMsgRegisterAck()
            : base(PCOS.MsgRegisterAck)
        {
        }

        static public PCOSMsgRegisterAck Parse(ArraySegment<byte> raw)
        {
            PCOSMsgRegisterAck regack = new PCOSMsgRegisterAck();

            regack.ParseHeader(raw);
            regack.ParseMessageBlock(raw);

            if (regack.MessageBlocks.Count > 0)
            {
                int offset = regack.MessageBlocks[0].BlockData.Offset;
                regack.iMAT = new ArraySegment<byte>(regack.MessageBlocks[0].BlockData.Array, offset, regack.MessageBlocks[0].BlockLength);
                regack.strMAT = BitConverter.ToString(regack.iMAT.Array, regack.iMAT.Offset, regack.iMAT.Count);
            }

            return regack;
        }
        public override string ToString()
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append(base.ToString());
            for (int x = 0; x < MessageBlocks.Count; x++)
                sb.Append(MessageBlocks[x]);
            sb.Append("MAT=");
            sb.Append(this.strMAT);
            return sb.ToString();
        }
    }
}
