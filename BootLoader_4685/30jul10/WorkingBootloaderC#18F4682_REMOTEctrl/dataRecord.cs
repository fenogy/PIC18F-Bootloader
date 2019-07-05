using System;
using System.Collections.Generic;
//using System.Linq;
using System.Text;

namespace WindowsFormsApplication1
{
    class dataRecord
    {
        public byte delimeter;
        public byte DataLength;
        public byte DataAddressH;
        public byte DataAddressL;
        public byte DataType;
        public int checksum;
        public byte[] data = new byte[60];
        public byte Error;
        public byte EndofLine = 0x0D;
        public byte pktlength;
        
         public  void clearRecord()
        {
            delimeter=0;
             DataLength=0;
             DataAddressH=0;
             DataAddressL=0;
             DataType=0;
             checksum=0;
             for(int y=0;y<60;y++)
             {
                 data[y]=0;
             }
             Error = 0;
             pktlength = 0;
        }

    }
   
}
    
