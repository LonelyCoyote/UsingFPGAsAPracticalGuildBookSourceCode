/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"
#include "EEPROM_1WIRE_DS24B33.h"
#include <iomanip>

void DisplayHelp();

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    const auto eeprom=EEPROM_1WIRE_DS24B33::GetInstance(device);
    eeprom->ReadDeviceID();
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
        if(commandType=='W')
        {
            std::vector<unsigned short> data;
            while(!cmd.eof())
            {
                unsigned short next;
                cmd >> std::hex >> next;
                data.push_back(next);
            }
            eeprom->WriteToMemory(address,data);
            continue;
        }
        if(commandType=='R')
        {
            unsigned short numBytes;
            cmd >> std::hex >> numBytes;

            const auto dataRead=eeprom->ReadFromMemory(address,numBytes);
            const auto lineCount=32;
            auto byteCounter=0;
            for(auto x:dataRead)
            {
                if((byteCounter%lineCount)==0)
                {
                    std::cout << std::endl;
                    std::cout << std::hex << std::setw(3) << std::setfill('0') << address << " ";
                }
                std::cout << std::hex << std::setw(2) << std::setfill('0') << x << " ";
                address++;
                byteCounter++;
            }
            std::cout << std::endl;


            continue;
        }
        std::cout << "Bad command" << std::endl;
    }



    
}

/***********************************************************************************************************************
***********************************************************************************************************************/
void DisplayHelp()
{
    std::cout << "COMMANDS AND FORMAT" << std::endl;
    std::cout << "Q to quit." << std::endl;
    std::cout << "H to display this help again" << std::endl;
    std::cout << "To write to the EEPROM Format is:" << std::endl;
    std::cout << "W AAA D1 D2 D3 ..." << std::endl;
    std::cout << "Where AAA = address to write to in hexadecimal" << std::endl;
    std::cout << "D1 D2 etc = data to write in hexadecimal" << std::endl << std::endl;
    std::cout << "To read from the EEPROM Format is:" << std::endl;
    std::cout << "R AAA NN" << std::endl;
    std::cout << "Where AAA = address to read from in hexadecimal" << std::endl;
    std::cout << "NN is the number of bytes to read in hexadecimal" << std::endl;
}


/***********************************************************************************************************************
***********************************************************************************************************************/
void UnitTest1(const OKFPGAModule& device, const int key)
{
    static auto eeprom=EEPROM_1WIRE_DS24B33::GetInstance(device);
    if(key>0)
    {
        const auto ID=eeprom->ReadDeviceID();
        for(size_t x=0;x!=ID.size();x++)
        {
            std::cout << std::fixed << std::setw(2) << std::setfill('0') << std::hex << static_cast<unsigned short>(ID[ID.size()-1-x]);
        }
        std::cout << std::endl;

        std::vector<unsigned short> test_data({0xDE,0xAD,0x55,0xAA,0xBA,0xBE});
        //eeprom->WriteToMemory(0x0160,test_data);
        const auto data=eeprom->ReadFromMemory(0x160,8);
    }
}

// EOF *****************************************************************************************************************
