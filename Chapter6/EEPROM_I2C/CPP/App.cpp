/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"

void DisplayHelp();
void WriteToEEPROM(const OKFPGAModule& device,unsigned short address,unsigned short data);
unsigned short ReadFromEEPROM(const OKFPGAModule& device,unsigned short address);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    DisplayHelp();
    while(true)
    {
        std::string commandString;
        std::getline(std::cin,commandString);
        if(commandString=="Q") return;
        if(commandString=="H")
        {
            DisplayHelp();
        }

        std::istringstream cmd(commandString);
        char commandType;
        cmd >> commandType;
        unsigned short address;
        cmd >> std::hex >> address;
        unsigned short data;
        if(commandType=='W')
        {
            cmd >> std::hex >> data;
            WriteToEEPROM(device,address,data);
            continue;
        }
        if(commandType=='R')
        {
            auto data=ReadFromEEPROM(device,address);
            std::cout << std::hex << data << std::endl;
            continue;
        }
        std::cout << "Bad command" << std::endl;
    }
    
}

/***********************************************************************************************************************
***********************************************************************************************************************/
void WriteToEEPROM(const OKFPGAModule& device,unsigned short address,unsigned short data)
{
    // Write address and data to wire in's
    device.SetWireIn(0x01,address);
    device.SetWireIn(0x00,data);
    device.UpdateWireIns();

    // Trigger and wait for completion
    device.ActivateTriggerIn(0x00,0);

    // Get wire out 00 and check for done, until done is set
    while(true)
    {
        device.UpdateWireOuts();
        const auto feedback=device.GetWireOut(0x00);
        if((feedback&0x8000)!=0) break;
    }
}

/***********************************************************************************************************************
***********************************************************************************************************************/
unsigned short ReadFromEEPROM(const OKFPGAModule& device,unsigned short address)
{
    // Prefix the address with the read command
    address|=0x8000;

    // Write address to wire in
    device.SetWireIn(0x01,address);
    device.UpdateWireIns();

    // Trigger and wait for completion
    device.ActivateTriggerIn(0x00,0);

    // Get wire out 00 and check for done, until done is set
    unsigned short feedback;
    while(true)
    {
        device.UpdateWireOuts();
        feedback=device.GetWireOut(0x00);
        if((feedback&0x8000)!=0) break;
    }

    feedback&=0x00FF;
    return feedback;
}


/***********************************************************************************************************************
***********************************************************************************************************************/
void DisplayHelp()
{
    std::cout << "COMMANDS AND FORMAT" << std::endl;
    std::cout << "Q to quit." << std::endl;
    std::cout << "H to display this help again" << std::endl;
    std::cout << "To write to the EEPROM Format is:" << std::endl;
    std::cout << "W AAA DD" << std::endl;
    std::cout << "Where AAA = address to write to in hexadecimal" << std::endl;
    std::cout << "DD = data to write in hexadecimal" << std::endl << std::endl;
    std::cout << "To read from the EEPROM Format is:" << std::endl;
    std::cout << "R AAA" << std::endl;
    std::cout << "Where AAA = address to read from in hexadecimal" << std::endl;
}

// EOF *****************************************************************************************************************
