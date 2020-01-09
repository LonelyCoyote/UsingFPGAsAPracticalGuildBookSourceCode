/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"
#include <iomanip>

void R2RDAC_Control(const OKFPGAModule& device,int key);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    auto kb=KeyBoard<OKFPGAModule>();
    kb.InstallKeyHandler(R2RDAC_Control);
    std::cout << "Use the up or down arrow key to change the value of the R2R DAC Output." << std::endl;
    kb.ShowConsoleCursor(false);
    kb.RunKeyHandler(device);
}

/***********************************************************************************************************************
8Bit R2R DAC Control
***********************************************************************************************************************/
void R2RDAC_Control(const OKFPGAModule& device, const int key)
{
    static unsigned short dacValue=0x0000;
    static auto updateRequired=true;
    
    if(key==VK_UP)
    {
        if(dacValue==0x00FF) return;
        updateRequired=true;
        dacValue++;
    }

    if(key==VK_DOWN)
    {
        if(dacValue==0x0000) return;
        updateRequired=true;
        dacValue--;
    }

    if(!updateRequired) return;
    updateRequired=false;

    const double refVolts=6.65;
    const double counts=1<<8;
    const double voltsPerBit=refVolts/counts;
    const double dacOutputVoltage=dacValue*voltsPerBit;

    std::cout << std::fixed << std::setprecision(2) << dacOutputVoltage << " Volts\r";

    // Write the DAC value and activate trigger in
    device.SetWireIn(0x00,dacValue,0xFFFF,true);
    device.ActivateTriggerIn(0x00,0);
}


// EOF *****************************************************************************************************************
