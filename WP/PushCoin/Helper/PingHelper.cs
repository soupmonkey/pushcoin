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

using PushCoin.Message;

namespace PushCoin.Helper
{

    public class PingPongEventArgs : EventArgs
    {
        public PCOSMessageBase Message { get; internal set; }
        public PingPongEventArgs(PCOSMessageBase pcogmsg)
        {
            this.Message = pcogmsg;
        }
    }  
 
    public class PingHelper
    {
        private PCOSMsgPing ping = new PCOSMsgPing();

        public PingHelper()
        {
        }

        #region PingPongRequest
        public void PingPushCoinServer()
        {
            var url = "https://api.pushcoin.com:20001/pcos/";

            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(url);
            webRequest.Method = "POST";
            webRequest.ContentType = "application/PCOS";

            // Start the request
            webRequest.BeginGetRequestStream(new AsyncCallback(GetRequestStreamCallback), webRequest);    
        }
        private void GetRequestStreamCallback(IAsyncResult asynchronousResult)
        {
            HttpWebRequest webRequest = (HttpWebRequest)asynchronousResult.AsyncState;
            // End the stream request operation
            System.IO.Stream postStream = webRequest.EndGetRequestStream(asynchronousResult);

            // Add the post data to the web request
            postStream.Write(ping.Bytes, 0, ping.Bytes.Length);
            postStream.Close();

            // Start the web request
            webRequest.BeginGetResponse(new AsyncCallback(GetResponseCallback), webRequest);
        }
        private void GetResponseCallback(IAsyncResult asynchronousResult)
        {    
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
                    PCOSMessageBase msg = PCOSMsgFactory.Parse(raw);

                    OnPingPongResponse(this, new PingPongEventArgs(msg));
                }
                streamResponse.Close();
                inputstream.Close();
                response.Close();
            }
            catch (WebException e)
            {
            }
        }
        #endregion

        #region event delagate
        public delegate void PingPongResponseHandler(object sender, PingPongEventArgs data);
        public event PingPongResponseHandler PingPongResponse;
        private void OnPingPongResponse(object sender, PingPongEventArgs data)
        {
            if (PingPongResponse != null)
            {
                PingPongResponse(this, data);
            }
        }  

        #endregion
    }
}
