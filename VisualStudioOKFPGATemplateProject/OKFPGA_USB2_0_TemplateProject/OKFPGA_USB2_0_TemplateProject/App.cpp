/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"

void LEDControl(const OKFPGAModule& device,int key);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    std::vector<unsigned short> items;
    items.reserve(1000);
    for(auto x=0; x<1000; x++)
    {
        items.push_back(x+1);
    }
    device.WriteToPipeIn(0,items);
    ::Sleep(100);

    auto pipeOutData=device.ReadFromPipeOut(0x00,1000);

    // Allow the user to control the LED's
    KeyBoard<OKFPGAModule> kb;
    KeyBoard<OKFPGAModule>::ShowConsoleCursor(false);
    kb.InstallKeyHandler(LEDControl);
    std::cout << "Use the left and right arrow keys to select the LED you want to change the state of." << std::endl;
    std::cout << "Use the up or down arrow key to toggle the selected LED on or off." << std::endl;
    kb.RunKeyHandler(device);
}

/***********************************************************************************************************************
The template application provides control of the LED's via the console
***********************************************************************************************************************/
void LEDControl(const OKFPGAModule& device, const int key)
{
    static std::string ledBits("00000000");
    static std::string ledStates("00000000");
    static auto toggle=false;
    static auto activeBit=0;
    static auto updateRateCount=0;

    updateRateCount++;
    if(updateRateCount==10)
    {
        toggle=!toggle;
        updateRateCount=0;
    }

    ledBits=ledStates;

    if(key==VK_LEFT)
    {
        if(activeBit==0)
        {
            activeBit=7;
        }
        else
        {
            activeBit--;
        }
    }
    if(key==VK_RIGHT)
    {
        activeBit++;
        activeBit%=8;
    }
    if(key==VK_UP || key==VK_DOWN)
    {
        ledStates[activeBit]=ledStates[activeBit]=='0'?'1':'0';
    }

    ledBits[activeBit]=toggle?'#':ledStates[activeBit];

    std::cout << "LED States=> " << ledBits <<'\r';

    // Convert the bits string into a unsigned short
    unsigned short data=0;
    for(size_t x=0; x<ledStates.size(); x++)
    {
        if(ledStates[x]=='1')
        {
            data|=(1<<x);
        }
    }

    // Write the LEDs to the FPGA
    device.SetWireIn(0x00,data,0xFFFF,true);
}


// EOF *****************************************************************************************************************
