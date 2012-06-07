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

using System.IO.IsolatedStorage;

namespace PushCoin
{
    public class PCSettings
    {
        static private string kPEMPublicKey = "PEMPublicKey";
        static private string kPEMPrivateKey = "PEMPrivateKey";
        static private string kMAT = "MAT";
        static private string kRegistered = "Registered";
        static private string kRegDatetime = "RegDatetime";

        static private IsolatedStorageSettings myisosettings = IsolatedStorageSettings.ApplicationSettings;

        static public void Initialize()
        {
        }

        static public void Save()
        {
            myisosettings.Save();
        }

        static new public string ToString()
        {
            return myisosettings.ToString();
        }

        static public string PEMPublic
        {
            get
            {
                if (PCSettings.myisosettings.Contains(PCSettings.kPEMPublicKey))
                    return (string)PCSettings.myisosettings[PCSettings.kPEMPublicKey];
                else
                    return string.Empty;
            }
            set { PCSettings.myisosettings[kPEMPublicKey] = value; }
        }
        static public string PEMPrivate
        {
            get
            {
                if (PCSettings.myisosettings.Contains(PCSettings.kPEMPrivateKey))
                    return (string)PCSettings.myisosettings[PCSettings.kPEMPrivateKey];
                else
                    return string.Empty;
            }
            set { PCSettings.myisosettings[kPEMPrivateKey] = value; }
        }
        static public string MAT
        {
            get
            {
                if (PCSettings.myisosettings.Contains(PCSettings.kMAT))
                    return (string)PCSettings.myisosettings[PCSettings.kMAT];
                else
                    return string.Empty;
            }
            set { PCSettings.myisosettings[kMAT] = value; }
        }
        static public bool Registered
        {
            get
            {
                if (PCSettings.myisosettings.Contains(PCSettings.kRegistered))
                    return (bool)PCSettings.myisosettings[PCSettings.kRegistered];
                else
                    return false;
            }
            set { PCSettings.myisosettings[kRegistered] = value; }
        }
        static public DateTime RegDatetime
        {
            get
            {
                if (PCSettings.myisosettings.Contains(PCSettings.kRegDatetime))
                    return (DateTime)PCSettings.myisosettings[PCSettings.kRegDatetime];
                else
                    return DateTime.Now;
            }
            set { PCSettings.myisosettings[kRegDatetime] = value; }
        }
    }
}
