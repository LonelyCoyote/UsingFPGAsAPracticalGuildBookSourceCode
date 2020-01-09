/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "MicroBlazeCommunicator.h"
#include <iostream>

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    auto comm=MicroBlazeCommnicator(device);
    std::cout << "Just press enter (an empty command) to exit" << std::endl;
    std::cout << "Enter a command to send to the MicroBlaze Processor, the processor will respond accordinlgy." << std::endl;
    std::cout << "If the command is not recognized it will simply echo the response." << std::endl;
    std::cout << "Current List of Commands: " << std::endl;
    std::cout << "HELLO" << std::endl;
    std::cout << "ONTIMER?" << std::endl;
    std::cout << std::endl;

    while(true)
    {
        std::string command;
        std::getline(std::cin,command);
        if(command.empty()) break;
        comm.WriteCommand(command);
        std::cout << "MicroBlaze-> " << comm.GetResponse() << std::endl;
    }
}

// EOF *****************************************************************************************************************
