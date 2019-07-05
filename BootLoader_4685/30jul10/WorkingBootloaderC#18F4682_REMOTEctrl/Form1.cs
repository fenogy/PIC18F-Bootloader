using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using System.IO;
using System.Threading;
//Last modified date 29Jul'10 1218 hrs
namespace WindowsApplication1
{
    public partial class Form1 : Form
    {
        string line="start";
        byte DataCount=5, k, t, portStatus = 0, DataSendStatus = 0;
        byte ACKSTATUS = 0, ReciveAck = 0, XON_OFF=0;
        byte[] SendBuffer = new byte[71];
        char[] TempData = new char[64];
        dataRecord Rec = new dataRecord();
        int CalCheckval, TempAddress, TempVal = 0;
        Int32 count,Lcount=0;
        byte[] startByte = new byte[1];
        string ComName;
        int dataBits = 8, baudRate;
        SerialPort hSp;

        char[] dev = new char[81];
        

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            string[] ports = SerialPort.GetPortNames();
            foreach (string port in ports)
            {
                comboBox1.Items.Add(port);
            }

            string[] BaudRates = { "4800", "9600", "19200", "38400", "57600", "115200" };

            foreach (string BaudRate in BaudRates)
            {
                comboBox2.Items.Add(BaudRate);
            }

            comboBox1.SelectedIndex = 0;
            comboBox2.SelectedIndex = 2;
            
        }       

        private void button1_Click(object sender, EventArgs e)    //load hex file i.e. create the modified hex------------------
        {
            DataSendStatus=0;
            Rec.clearRecord();

            /*if (textBox1.Text == null)
            {
                MessageBox.Show("LOAD THE HEX FILE");
                goto endofoperation;
            }*/

            System.IO.StreamReader file = new System.IO.StreamReader(textBox1.Text);  
            //read the data class
            FileStream fs = new FileStream("E:log.txt", FileMode.Create);
            // Create the writer for data.

            ///////////////////////////
            //StreamWriter w = new StreamWriter(fs); 

            ////////

            BinaryWriter w = new BinaryWriter(fs);
            // Write data to Test.data.

            do
            {                
                while (true)
                {
                    if (Rec.Statas == 2)
                    {
                        Rec.Statas = 4;
                        break;
                    }

                    line = file.ReadLine(); // : mark
                    
                    if (((Rec.InitAddress + 63) >= 0x17E74) && ((Rec.InitAddress + 63) <= 0x17FC4))
                    //if (((Rec.InitAddress + 63) >= 0x13E9A) && ((Rec.InitAddress + 63) <= 0x13FDC))
                    {
                        MessageBox.Show("PROGRAM FILE OVERWRITE THE BOOTLOADER.............");
                        Rec.Error = 1;
                        break;
                    }
                    
                    if (line == null)
                    {
                        MessageBox.Show("Empty File.............");
                        Rec.Error = 1;
                        break;
                    }
                    
                    if (Rec.delimeter != (byte)line[0])
                    {
                        MessageBox.Show("Error File.............");
                        Rec.Error = 1;
                        break;
                    }
                    
                    k = 1;
                    t = 0;
                    do
                    {
                        TempVal = ascii2hex(line[k]); // byte length
                        k++;
                        TempVal = ((TempVal <<= 4) | ascii2hex(line[k]));
                        TempData[t] = (char)(TempVal & 0xFF);
                        k++;
                        t++;
                    } while (t <= (TempData[0] + 4));
                    
                    CalCheckval = 0;
                    t--;
                    while (t > 0)
                    {
                        t--;
                        CalCheckval += (int)TempData[t];
                    }
                    if (TempData[TempData[0] + 4] != (byte)((0 - CalCheckval) & 0xFF))
                    {
                        MessageBox.Show("Error File curr............");
                        Rec.Error = 1;
                        break;
                    }
                    
                    if (TempData[3] == Rec.ExtendedAddress)
                    {
                        Rec.Statas = 1;
                        break;
                    }
                    
                    if (TempData[3] == Rec.EndFile)
                    {
                        Rec.Statas = 2;
                        break;
                    }
                    
                    TempAddress = TempData[1];
                    TempAddress = (TempAddress << 8) | TempData[2];
                    Rec.PrenAddress &= 0xFF0000;
                    Rec.PrenAddress |= TempAddress;
                    
                    if ((Rec.PrenAddress + TempData[0]) > (Rec.InitAddress + 64))
                    {
                        if (Rec.Statas == 5)
                        {
                            Rec.Statas = 6;
                            break;
                        }
                        Rec.Statas = 3;                        
                        break;
                    }
                    
                    //Rec.Statas = 4;
                    Rec.Statas = 0;
                    for (t = 4; t < (TempData[0] + 4); t++)
                    {
                        Rec.Data[DataCount] = TempData[t];
                        DataCount++;
                    }
                    
                    if (DataCount == 68)
                    {
                        Rec.Statas = 5;
                        break;
                    }
                }
                if (Rec.Error == 1)
                {
                    break;
                }
                
                if ((DataCount > 5) && (Rec.Statas != 6))
                {
                    Rec.Data[0] = Rec.delimeter;
                    Rec.Data[1] = (char)0x40;
                    TempAddress = Rec.InitAddress;
                    Rec.Data[4] = (char)(TempAddress & 0xFF);
                    TempAddress >>= 8;
                    Rec.Data[3] = (char)(TempAddress & 0xFF);
                    Rec.Data[2] = (char)(TempAddress >> 8);

                    if (Rec.InitAddress == 0x000000)
                    {
                        Rec.TempIntData[0] = Rec.Data[5];
                        Rec.TempIntData[1] = Rec.Data[6];
                        Rec.TempIntData[2] = Rec.Data[7];
                        Rec.TempIntData[3] = Rec.Data[8];
                        
                        Rec.Data[5] = (char)0x4F;
                        Rec.Data[6] = (char)0xEF;
                        Rec.Data[7] = (char)0xBF;
                        Rec.Data[8] = (char)0xF0;
                    }
                    
                    CalCheckval = 0;
                    for (DataCount = 1; DataCount < 69; DataCount++)
                    {
                        CalCheckval += Rec.Data[DataCount];
                    }
                    
                    Rec.Data[69] = (char)(0 - CalCheckval);
                    Rec.Data[70] = '\n';
                    //Rec.Data[70] = (char)0x0D;
                    Rec.Data[71] = '\r';
                    Rec.Data[71] = (char)0x0A;

                    for (int i = 0; i < 72; i++)
                    {
                        w.Write((char)(Rec.Data[i] & 0xFF));
                        if (Lcount == 0)
                        dev[i] = Rec.Data[i];
                    }
                    Lcount++;

                    for (int i = 0; i < 72; i++) 
                        Rec.Data[i] = (char)0xFF;  
                }

                DataCount = 5;
                
                if (Rec.Statas == 1)
                {
                    Rec.PrenAddress &= 0xFFFF;
                    TempAddress = TempData[5];
                    TempAddress <<= 16;
                    TempAddress &= 0xFF0000;
                    Rec.PrenAddress |= TempAddress;
                }
                
                if (Rec.Statas == 2)
                {
                    Rec.InitAddress = 0x017FC0;
                    for (t = 0; t < 4; t++)
                    {
                        Rec.Data[DataCount] = Rec.TempIntData[t];
                        DataCount++;
                    }
                }
                
                if ((Rec.Statas == 3) || (Rec.Statas == 6))
                {
                    Rec.InitAddress = Rec.PrenAddress;
                    for (t = 4; t < (TempData[0] + 4); t++)
                    {
                        Rec.Data[DataCount] = TempData[t];
                        DataCount++;
                    }
                }
                
                if (Rec.Statas == 4)
                {
                    MessageBox.Show("Loading Of Hex File Complet");
                    DataSendStatus = 1;
                    break;
                }
            } while (true);

            progressBar1.Maximum = Lcount + 3;// 3 is not a good value
            progressBar1.Minimum = 0;
            w.Close();
            fs.Close();
            file.Close(); 
       //   endofoperation:
         //   Rec.Statas = 0;

        }

        private void button2_Click(object sender, EventArgs e)  ///write to pic----------------------------------------------------
        {
           // System.IO.StreamReader LogReader = new System.IO.StreamReader("D:log.txt");
            System.IO.StreamReader LogReader = new System.IO.StreamReader("E:log.txt");  
          //  string LogLine;
            int charcount;
            char[] temp = new char[81]; 
           // char TempLOGVal;

           // LogLine = LogReader.ReadToEnd();
            Lcount = 0;
            
            do

            {    
               /* t=0;
                do
                {
                    temp[t++] = (char)LogLine[charcount];
                } while ((LogLine[charcount] != 0x0A) && (LogLine[charcount-1] != 0x0D));
                charcount++;    */

                charcount=LogReader.ReadBlock(temp, 0, 72);
                //charcount = LogReader.Read();
               // LogLine = LogReader.ReadLine();
                if (charcount == 0x0000)
                {
                    SendBuffer[0] = (byte)0xFF;                
                    hSp.Write(SendBuffer, 0, 1);
                    MessageBox.Show("Writing Process Complet");
                    break;
                }            
                t = 0;
                do
                {
                    SendBuffer[t] = (byte)temp[t];  // byte length 
                    t++;
                    
                } while (t < 70);
                //SendBuffer[70] = (byte)0x0D;
            Send_Data:
                hSp.Write(SendBuffer,0,70);
                count = 0;
            wait:
                count++;
                /*if (count >= 1000000)
                {
                    MessageBox.Show("Communication With the Device Have the Error");
                    button2.Enabled = false;
                    break;
                }*/

                if (ACKSTATUS == 0)
                    goto wait;

                ACKSTATUS = 0; 

                if(ReciveAck == 0xFF)
                    goto Send_Data;

               // Linecount++;
               // progressBar1.Value = 5*Lcount/2;
                Lcount++;
                progressBar1.Value = 3 + Lcount; 
            } while (line != null);

            LogReader.Close();
            Application.Exit();
        }

        private void button3_Click(object sender, EventArgs e)    /// Browsing-------------------------------------------------
        {
            OpenFileDialog fdlg = new OpenFileDialog();
            fdlg.Title = "Hex file uploader";
            fdlg.InitialDirectory = @"c:\";
            fdlg.Filter = "HEX Files|*.hex";
            fdlg.FilterIndex = 2;
            fdlg.RestoreDirectory = true;
            if (fdlg.ShowDialog() == DialogResult.OK)
            {
                textBox1.Text = fdlg.FileName;
            }
        }

        public void SerialReceive(object sender, SerialDataReceivedEventArgs e)
        {
            int val = 0;
            val = hSp.ReadByte();
            //  hSp.Read(comBuffer, 0, bytes);
           /* if ((val == 0x06) && (endSendFile == 1))//XON -->0x11
            {
                startSendFile = 1;

            }
            if (((val == 0x06) | (val == 0xFF)) && (Ack == 0))
            {
                ReceiveStatus = (byte)val;
                Ack = 1;

            }
            if (val == 0xFF)
            {
                MessageBox.Show("NAK ");
            }*/

            if (((val == 0x06) || (val == 0xFF)) && (ACKSTATUS == 0))
            {
                ReciveAck = (byte)val;
                ACKSTATUS = 1;

            }

            if (val == 0x11) //11
            {
                XON_OFF = 1;
                
                /*if(DataSendStatus==1)                   
                    button2.Enabled = true;*/
                
            }

            if (val == 0x13)//13
            {
                XON_OFF = 0;
             //   button2.Enabled = false;
            }
            val = 0;
        }



        private void button4_Click(object sender, EventArgs e)
        {
            if (portStatus == 0)
            {
                ComName = comboBox1.SelectedItem.ToString();
                baudRate = Convert.ToInt32(comboBox2.SelectedItem.ToString());
                hSp = new SerialPort(ComName, baudRate, System.IO.Ports.Parity.None, dataBits, System.IO.Ports.StopBits.One);

                try
                {

                    hSp.Open();
                    button4.Text = "Disconnect";
                    //MessageBox.Show("Port Opened");
                    Thread trd = new Thread(new ThreadStart(this.ThreadTask));
                    trd.IsBackground = true;
                    trd.Start();


                }
                catch (Exception ec)
                {
                    MessageBox.Show(ec.Message);
                }
                hSp.DataReceived += new SerialDataReceivedEventHandler(SerialReceive);
                portStatus = 1;

            }
            else if (portStatus == 1)
            {

                hSp.Close();
                button4.Text = "Connect";
                portStatus = 0;

            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        byte ascii2hex(char ascii)
        {
            byte hexVal = 0;

            if (ascii <= '9')
            {
                hexVal = (byte)(Convert.ToByte(ascii) - 0x30);
            }

            else
            {

                hexVal = (byte)(Convert.ToByte(ascii) - 0x41 + 0x0A);
            }

            return hexVal;
        }

        private void ThreadTask()
        {
            while (true)
            {
                try
                {
                    this.Invoke(new UpdateHandler(changeText));
                }
                catch (Exception ec)
                {
                   
                    break;
                }

                Thread.Sleep(20);  //sleep for 20 ms

                if (XON_OFF == 0)
                {
                    try
                    {
                        //hSp.Open();
                        startByte[0] = 0x62;  // 'b'
                        hSp.Write(startByte, 0, 1);
                        Thread.Sleep(10);
                        startByte[0] = 0x6c;  // 'l'
                        hSp.Write(startByte, 0, 1);
                        Thread.Sleep(10);
                        //hSp.Close();
                    }
                    catch (Exception ec)
                    {

                        break;
                    }
                }
                
            }
        }

        private void changeText()
        {            
            if ((XON_OFF == 1) && (DataSendStatus==1))
            {
                button2.Enabled = true;
            }
            else if (XON_OFF == 0)
            {
                button2.Enabled = false;

            }
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }
        public delegate void UpdateHandler();
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void progressBar1_Click(object sender, EventArgs e)
        {

        }        
    }
}