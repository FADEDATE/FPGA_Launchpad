#include <SoftwareSerial.h>
#include <hidboot.h>
#include <usbhub.h>
#include <MIDI.h>
SoftwareSerial fpga(7,8);
MIDI_CREATE_INSTANCE(HardwareSerial,Serial,HardwareMIDI);
#ifdef dobogusinclude
#include <spi4teensy3.h>
#endif
#include <SPI.h>

class KbdRptParser : public KeyboardReportParser
{
  public:
  uint8_t re;
  uint8_t note;
  uint8_t ctone=0;
  int scale=0; 
  uint8_t flag=0;
  uint8_t cflag=0;      
    void notechanceOn(uint8_t key);
    void notechanceOff(uint8_t key);
  protected:
    

    void OnKeyDown  (uint8_t mod, uint8_t key);
    void OnKeyUp  (uint8_t mod, uint8_t key);
    void OnKeyPressed(uint8_t key);
};
#define do_l 48
#define re_l 50
#define mi_l 52
#define fa_l 53
#define so_l 55
#define la_l 57
#define xi_l 59

#define do_s 60
#define re_s 62 
#define mi_s 64
#define fa_s 65
#define so_s 67
#define la_s 69
#define xi_s 71

#define do_h 72
#define re_h 74
#define mi_h 76
#define fa_h 77
#define so_h 79
#define la_h 81
#define xi_h 83
void KbdRptParser::OnKeyDown(uint8_t mod, uint8_t key)
{

  uint8_t c = OemToAscii(mod, key);
  if (c)
    OnKeyPressed(c);
}

int zero=0;
void KbdRptParser::notechanceOn(uint8_t key)
{
      
    if(ctone==1 && (key-'n'!=0))
        flag++;
        
  switch(key-'a'){
    case 0 :HardwareMIDI.sendNoteOn(do_l+scale+ctone,127,3);break;
    case 1 :HardwareMIDI.sendNoteOn(la_l+scale,127,3);break;
    case 2 :HardwareMIDI.sendNoteOn(do_s+scale+ctone,127,3);break;
    case 3 :HardwareMIDI.sendNoteOn(la_s+scale+ctone,127,3);break;
    case 4 :HardwareMIDI.sendNoteOn(mi_h+scale,127,3);break;

    case 5 :HardwareMIDI.sendNoteOn(re_l+scale+ctone,127,3);break;
    case 6 :HardwareMIDI.sendNoteOn(xi_l+scale+ctone,127,3);break;
    case 7 :HardwareMIDI.sendNoteOn(re_s+scale+ctone,127,3);break;  
    case 8 :HardwareMIDI.sendNoteOn(xi_s+scale,127,3);break;  
    case 9 :HardwareMIDI.sendNoteOn(fa_h+scale+ctone,127,3);break;  

    case 10 :HardwareMIDI.sendNoteOn(mi_l+scale,127,3);break;
    case 11 :scale = -12;HardwareMIDI.sendNoteOn(60,127,1);break;//up scale
    case 12 :HardwareMIDI.sendNoteOn(mi_s+scale,127,3);break;
    case 13 :ctone=1;HardwareMIDI.sendNoteOn(65,0,2); break;   // # up tone
    case 14 :HardwareMIDI.sendNoteOn(so_h+scale+ctone,127,3);break;

    case 15 :HardwareMIDI.sendNoteOn(fa_l+scale+ctone,127,3);break;
    case 16 :scale=0;HardwareMIDI.sendNoteOn(65,127,1);break;//reback scale
    case 17 :HardwareMIDI.sendNoteOn(fa_s+scale+ctone,127,3);break;
    case 18:HardwareMIDI.sendNoteOn(do_h+scale+ctone,127,3);break;
    case 19:HardwareMIDI.sendNoteOn(la_h+scale+ctone,127,3);break;

    case 20:HardwareMIDI.sendNoteOn(so_l+scale+ctone,127,3);break;
    case 21:scale = 12;HardwareMIDI.sendNoteOn(71,127,1);break;//down scale
    case 22:HardwareMIDI.sendNoteOn(so_s+scale+ctone,127,3);break;
    case 23:HardwareMIDI.sendNoteOn(re_h+scale+ctone,127,3);break;
    case 24:HardwareMIDI.sendNoteOn(xi_h+scale,127,3);break;
    default:break;
    
    
  }
}


void KbdRptParser::notechanceOff(uint8_t key)
{

  
  switch(key-'a'){
    case 0 :HardwareMIDI.sendNoteOff(do_l+scale+ctone,127,3);break;
    case 1 :HardwareMIDI.sendNoteOff(la_l+scale,127,3);break;
    case 2 :HardwareMIDI.sendNoteOff(do_s+scale+ctone,127,3);break;
    case 3 :HardwareMIDI.sendNoteOff(la_s+scale+ctone,127,3);break;
    case 4 :HardwareMIDI.sendNoteOff(mi_h+scale,127,3);break;

    case 5 :HardwareMIDI.sendNoteOff(re_l+scale+ctone,127,3);break;
    case 6 :HardwareMIDI.sendNoteOff(xi_l+scale+ctone,127,3);break;
    case 7 :HardwareMIDI.sendNoteOff(re_s+scale+ctone,127,3);break;  
    case 8 :HardwareMIDI.sendNoteOff(xi_s+scale,127,3);break;  
    case 9 :HardwareMIDI.sendNoteOff(fa_h+scale+ctone,127,3);break;  

    case 10 :HardwareMIDI.sendNoteOff(mi_l+scale,127,3);break;
    case 11 :scale = -12;HardwareMIDI.sendNoteOff(60,127,1);break;//up scale
    case 12 :HardwareMIDI.sendNoteOff(mi_s+scale,127,3);break;
    case 13 :ctone=0;HardwareMIDI.sendNoteOff(65,0,2); break;   // # up tone
    case 14 :HardwareMIDI.sendNoteOff(so_h+scale+ctone,127,3);break;

    case 15 :HardwareMIDI.sendNoteOff(fa_l+scale+ctone,127,3);break;
    case 16 :scale=0;HardwareMIDI.sendNoteOff(65,127,1);break;//reback scale
    case 17 :HardwareMIDI.sendNoteOff(fa_s+scale+ctone,127,3);break;
    case 18:HardwareMIDI.sendNoteOff(do_h+scale+ctone,127,3);break;
    case 19:HardwareMIDI.sendNoteOff(la_h+scale+ctone,127,3);break;

    case 20:HardwareMIDI.sendNoteOff(so_l+scale+ctone,127,3);break;
    case 21:scale = 12;HardwareMIDI.sendNoteOff(71,127,1);break;//down scale
    case 22:HardwareMIDI.sendNoteOff(so_s+scale+ctone,127,3);break;
    case 23:HardwareMIDI.sendNoteOff(re_h+scale+ctone,127,3);break;
    case 24:HardwareMIDI.sendNoteOff(xi_h+scale,127,3);break;
    default:break;
    
    
    
  }
    if(flag!=0 && ctone==0){
     ctone = 1;
     
    }
    if(flag)flag--;
        else ctone=0;
     

      
      
  
}
void KbdRptParser::OnKeyUp(uint8_t mod, uint8_t key)
{
  uint8_t c = OemToAscii(mod, key);
  notechanceOff(c);
}

void KbdRptParser::OnKeyPressed(uint8_t key){

     re = key-'a'+1;
    fpga.write(re);
    notechanceOn(key);
    fpga.write(zero);

  
  
}

USB     Usb;
//USBHub     Hub(&Usb);
HIDBoot<USB_HID_PROTOCOL_KEYBOARD>    HidKeyboard(&Usb);

KbdRptParser Prs;

uint8_t c;
void setup()
{
  HardwareMIDI.begin();
  Serial.begin( 115200 );
  fpga.begin(9600);
#if !defined(__MIPSEL__)
  while (!Serial); // Wait for serial port to connect - used on Leonardo, Teensy and other boards with built-in USB CDC serial connection
#endif
 Usb.Init();
  delay( 200 );

  HidKeyboard.SetReportParser(0, &Prs);
   HardwareMIDI.sendProgramChange(0,3);
   HardwareMIDI.sendProgramChange(15,2);
   HardwareMIDI.sendProgramChange(16,1);
}

void loop()
{
  Usb.Task();
  
  if(fpga.available())
  {
        c=fpga.read();
        
        HardwareMIDI.sendProgramChange(c,3);
  }
}
