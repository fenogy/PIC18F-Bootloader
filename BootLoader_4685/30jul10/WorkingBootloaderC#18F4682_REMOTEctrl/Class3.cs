using System;
using System.Collections.Generic;
using System.Text;

namespace WindowsApplication1
{
    class dataRecord 
    {
        public char delimeter = (char)0x3A;
        //public byte DataLength;
        public char EndFile = (char)0x01;
        public char ExtendedAddress = (char)0x04;
       // public byte DataAddressU;
        //public byte DataAddressH;
        //public byte DataAddressL;
        //public byte DataType;
        public byte Statas;
        public int  checksum;
        public int  InitAddress;
        public int PrenAddress;

        public char[] Data = new char[75];
        public char[] TempIntData = new char[4];
        public byte Error;
        //public char EndofLine = (char)0x0D;
        //public byte pktlength;
        
        public  void clearRecord()
        {
             InitAddress = 0;
             //DataLength=0;
             Statas = 0;
             PrenAddress = 0;
             InitAddress = 0;
             checksum = 0;
             Error = 0;
           //  DataAddressH=0;
           //  DataAddressL=0;
             //DataType=0;
             checksum=0;
             for(int y=0;y<75;y++)
             {
                 Data[y] = (char)0;
             }
             Error = 0;
             //pktlength = 0;
        }
    }
}
