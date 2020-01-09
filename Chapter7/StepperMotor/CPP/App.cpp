/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "StepperMotorController.h"
#include <iostream>
#include <fstream>

void RunTopLevel(const OKFPGAModule& device);
void RunScript(StepperMotorController& steppper,const std::string& fileName);

/***********************************************************************************************************************
Get a vector of parts from a string
***********************************************************************************************************************/
std::vector<std::string> split(const std::string &s,char delim) {
    std::stringstream ss(s);
    std::string item;
    std::vector<std::string> elems;
    while(std::getline(ss,item,delim)) {
        elems.push_back(item);
    }
    return elems;
}

/***********************************************************************************************************************
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    RunTopLevel(device);
}


/***********************************************************************************************************************
***********************************************************************************************************************/
void RunTopLevel(const OKFPGAModule& device)
{
    std::cout << "COMMANDS:" << std::endl;
    std::cout << "S 10 - set speed to 10 degrees per second" << std::endl;
    std::cout << "E - enable the motor" << std::endl;
    std::cout << "D - disable the motor" << std::endl;
    std::cout << "CW - set rotation direction to clockwise" << std::endl;
    std::cout << "CCW - set rotation to counter clockwise" << std::endl;
    std::cout << "NOSTOP - have motor move indefinetly" << std::endl;
    std::cout << "STOP - turn off motor moving indefinity" << std::endl;
    std::cout << "M 100 - move the motor 100 degrees" << std::endl;
    std::cout << "STATE - shows the status of the motor (MOVING,ENABLED AND DIRECTION)" << std::endl;
    std::cout << "RUNSCRIPT FILENAME.TXT - Runs a command script within the provided for file name."  << std::endl;
    std::cout << "QUIT - exit this application" << std::endl;

    auto stepper=StepperMotorController::Instance(device);

    while(true)
    {
        std::string line;
        std::getline(std::cin,line);
        auto parts=split(line,' ');
        if(parts.size()==1)
        {
            const auto command=parts[0];
            if(command=="E") stepper.Enable(true);
            if(command=="D") stepper.Enable(false);
            if(command=="CW") stepper.Direction(true);
            if(command=="CCW") stepper.Direction(false);
            if(command=="NOSTOP") stepper.Continuous(true);
            if(command=="STOP") stepper.Continuous(false);
            if(command=="STATE")
            {
                std::cout << "MOVING: " << (stepper.IsMoving()?"TRUE":"FALSE");
                std::cout << " | ENABLED: " << (stepper.Enabled()?"TRUE":"FALSE");
                std::cout << " | DIRECTION: " << (stepper.Direction()?"CW":"CCW");
                std::cout << std::endl;
            }
            if(command=="QUIT") return;
        }
        else if(parts.size()==2)
        {
            const auto command=parts[0];
            auto parser=std::istringstream(parts[1]);
            double value;
            parser >> value;
            if(command=="S")
            {
                stepper.SetSpeed(value);
            }
            if(command=="M")
            {
                stepper.Move(value);
            }
            if(command=="RUNSCRIPT")
            {
                std::cout << "Script Running... \r";
                RunScript(stepper,parts[1]);
                std::cout << "Script Completed    " << std::endl;
            }
        }
        else
        {
            std::cout << "SYNTAX ERROR" << std::endl;
        }
    }
}

/***********************************************************************************************************************
***********************************************************************************************************************/
void RunScript(StepperMotorController& stepper,const std::string& fileName)
{
    std::ifstream scriptFile;
    scriptFile.open(fileName);
    if(!scriptFile.is_open())
    {
        throw std::exception("Error opening script file.");
    }

    std::string line;

    while(std::getline(scriptFile,line))
    {
        auto parts=split(line,' ');
        if(parts.size()==1)
        {
            const auto command=parts[0];
            if(command=="E") stepper.Enable(true);
            if(command=="D") stepper.Enable(false);
            if(command=="CW") stepper.Direction(true);
            if(command=="CCW") stepper.Direction(false);
            if(command=="NOSTOP") stepper.Continuous(true);
            if(command=="STOP") stepper.Continuous(false);
        }
        else if(parts.size()==2)
        {
            const auto command=parts[0];
            auto parser=std::istringstream(parts[1]);
            double value;
            if(command=="S")
            {
                parser >> value;
                stepper.SetSpeed(value);
            }
            if(command=="M")
            {
                parser >> value;
                stepper.Move(value);
                ::Sleep(10);
                while(stepper.IsMoving())
                {
                    ::Sleep(20);
                }
            }
            if(command=="SLEEP")
            {
                DWORD sleepTime;
                parser >> sleepTime;
                ::Sleep(sleepTime);
            }
        }
    }

}




// EOF *****************************************************************************************************************
