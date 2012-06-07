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

using Org.BouncyCastle.Security;
using Org.BouncyCastle.Crypto.Generators;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Bcpg.OpenPgp;
using Org.BouncyCastle.X509;
using Org.BouncyCastle.Utilities.IO.Pem;
using Org.BouncyCastle.Pkcs;
using Org.BouncyCastle.Asn1.Pkcs;
using Org.BouncyCastle.Asn1;
using Org.BouncyCastle.Asn1.X9;
using Org.BouncyCastle.Asn1.X509;
using Org.BouncyCastle.Math;

using PushCoin.Message;

namespace PushCoin.Helper
{
    public class DSAHelper
    {
        public class RegisterResult
        {
            public string Message = "";
            public bool Registered = false;
        }

        #region keys
        private AsymmetricCipherKeyPair DSAKeys = null;
        private string _pempublickey = "";
        private string _pemprivatekey = "";

        public string PEMPublicKey { get { return _pempublickey; } set { _pempublickey = value; } }
        public string PEMPrivateKey { get { return _pemprivatekey; } set { _pemprivatekey = value; } }

        private ArraySegment<byte> _derpublickey;
        public ArraySegment<byte> DERPublicKey
        {
            get { return _derpublickey; }
            set { _derpublickey = value; }
        }
        private ArraySegment<byte> _derprivatekey;
        public ArraySegment<byte> DERPrivateKey
        {
            get { return _derprivatekey; }
            set { _derprivatekey = value; }
        }
        #endregion

        private string RegistrationID;

        #region event
        public delegate void OnRegisteredEvent(RegisterResult regresult);
        public event OnRegisteredEvent OnRegistered;
        #endregion

        public DSAHelper(string registrationid)
        {
            RegistrationID = registrationid;
            GenerateDSA();
        }

        public void RegisterWithPushCoinServer()
        {
            var url = "https://api.pushcoin.com:20001/pcos/";

            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(url);
            webRequest.Method = "POST";
            webRequest.ContentType = "application/PCOS";

            // Start the request
            webRequest.BeginGetRequestStream(new AsyncCallback(GetRequestStreamCallback), webRequest);
        }

        #region private
        private void GetRequestStreamCallback(IAsyncResult asynchronousResult)
        {
            HttpWebRequest webRequest = (HttpWebRequest)asynchronousResult.AsyncState;
            // End the stream request operation
            System.IO.Stream postStream = webRequest.EndGetRequestStream(asynchronousResult);

            PCOSMsgRegister pcosmsgRegister = new PCOSMsgRegister(this.RegistrationID, this.PEMPublicKey);
            //PCOSMsgRegister pcosmsgRegister = new PCOSMsgRegister(this.RegistrationID, this.DERPublicKey);

            // Add the post data to the web request
            postStream.Write(pcosmsgRegister.Bytes, 0, pcosmsgRegister.Bytes.Length);
            postStream.Close();

            // Start the web request
            webRequest.BeginGetResponse(new AsyncCallback(GetResponseCallback), webRequest);
        }
        private void GetResponseCallback(IAsyncResult asynchronousResult)
        {
            PCOSMessageBase retmsg = new PCOSMsgInvalid();
            try
            {
                HttpWebRequest webRequest = (HttpWebRequest)asynchronousResult.AsyncState;
                HttpWebResponse response;

                // End the get response operation
                response = (HttpWebResponse)webRequest.EndGetResponse(asynchronousResult);
                System.IO.Stream streamResponse = response.GetResponseStream();

                System.IO.BinaryReader inputstream = new System.IO.BinaryReader(streamResponse);

                if (inputstream.BaseStream.Length > 0)
                {
                    byte[] responsebytes = new byte[inputstream.BaseStream.Length];
                    int totalRead = 0;
                    while (totalRead < inputstream.BaseStream.Length)
                    {
                        responsebytes[totalRead++] = inputstream.ReadByte();
                    }

                    ArraySegment<byte> raw = new ArraySegment<byte>(responsebytes, 0, totalRead);
                    retmsg = PCOSMsgFactory.Parse(raw);
                }
                streamResponse.Close();
                inputstream.Close();
                response.Close();
            }
            catch (WebException e)
            {
            }

            DSAHelper.RegisterResult registerresult = new RegisterResult();
            if(retmsg is PCOSMsgRegisterAck)
            {
                PCOSMsgRegisterAck pcosregack = (PCOSMsgRegisterAck)retmsg;

                registerresult.Registered = true;
                registerresult.Message = "Registered Successful";

                PCSettings.PEMPublic = this.PEMPublicKey;
                PCSettings.PEMPrivate = this.PEMPrivateKey;
                PCSettings.MAT = Convert.ToBase64String(pcosregack.MAT);
                PCSettings.Registered = true;
                PCSettings.RegDatetime = DateTime.Now;

                // save it first...
                PCSettings.Save();
            }
            else if(retmsg is PCOSMsgError)
            {
                PCOSMsgError pcosmsgerr = (PCOSMsgError)retmsg;
                registerresult.Message = pcosmsgerr.ErrorCode + ":" + pcosmsgerr.Reason;
            }
            else
            {
                registerresult.Message = "Failed to registered with Push Coin server. Please try again at a later time.";
            }

            if (OnRegistered != null)
                OnRegistered(registerresult);
        }
        private void GenerateDSA()
        {
            //DSA Key Parameter Generator
            DsaParametersGenerator paramgen = new DsaParametersGenerator();
            //Initialize Key Parameter Generator
            paramgen.Init(512, 100, new SecureRandom());

            //DSA KeyGeneration Parameters 
            DsaKeyGenerationParameters param = new DsaKeyGenerationParameters(new SecureRandom(), paramgen.GenerateParameters());

            //DSA Key Pair Generator
            DsaKeyPairGenerator dsakpgen = new DsaKeyPairGenerator();
            //Initialize the Key Pair Generator
            dsakpgen.Init(param);

            //The DSA Keys!
            this.DSAKeys = dsakpgen.GenerateKeyPair();

            //Generate PEM format
            byte[] prvencoding = DSAHelper.EncodePrivateKey(this.DSAKeys.Private);
            this.PEMPrivateKey = Convert.ToBase64String(prvencoding);
            this.DERPrivateKey = new ArraySegment<byte>(prvencoding);

            byte[] pubencoding = SubjectPublicKeyInfoFactory.CreateSubjectPublicKeyInfo(this.DSAKeys.Public).GetDerEncoded();
            this.PEMPublicKey = Convert.ToBase64String(pubencoding);
            this.DERPublicKey = new ArraySegment<byte>(pubencoding);            
        }
        #endregion

        #region static
        static private byte[] EncodePrivateKey(AsymmetricKeyParameter akp)
        {
            PrivateKeyInfo info = PrivateKeyInfoFactory.CreatePrivateKeyInfo(akp);

            DerObjectIdentifier oid = info.AlgorithmID.ObjectID;

            if (oid.Equals(X9ObjectIdentifiers.IdDsa))
            {
                DsaParameter p = DsaParameter.GetInstance(info.AlgorithmID.Parameters);

                BigInteger x = ((DsaPrivateKeyParameters)akp).X;
                BigInteger y = p.G.ModPow(x, p.P);

                // TODO Create an ASN1 object somewhere for this?
                return new DerSequence(
                    new DerInteger(0),
                    new DerInteger(p.P),
                    new DerInteger(p.Q),
                    new DerInteger(p.G),
                    new DerInteger(y),
                    new DerInteger(x)).GetEncoded();
            }

            return (new byte[0]);
        }
        #endregion
    }
}
