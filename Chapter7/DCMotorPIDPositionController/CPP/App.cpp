/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "ConstantPositionPIDControl.h"
#include "PeriodicTimer.h"
#include "KeyBoard.h"

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    auto controller=ConstantPositionPIDControl(device);
    PeriodicTimer<ConstantPositionPIDControl>(&controller,&ConstantPositionPIDControl::Update,20);

    std::cout << "Just press enter to exit." << std::endl;
    std::cout << "Enter a number between -1.0 and +1.0 and the motor will move accordingly" << std::endl;
    std::cout << "Enter 'A?' to see angle." << std::endl;
    std::cout << "To clear the angle, (set the refrence point) enter 'R'" << std::endl;
    std::cout << "To Turn on the PID control, enter 'ON'" << std::endl;
    std::cout << "To Turn off the PID control, enter 'OFF'" << std::endl;
    std::cout << "To set PID values enter 'PID', we will then ask you to enter three values" << std::endl;
    std::cout << "To see the setpoint, enter 'SETPOINT', we will then ask you the value for the setpoint" << std::endl;
    std::cout << "To see the following error, enter 'ERROR'" << std::endl;
    std::cout << "To see the PID values enter 'PID?'" << std::endl;
    std::cout << "To see the setpoint, enter 'SETPOINT?'" << std::endl;
    std::cout << "To see the proportional error contribution, enter 'PE?'" << std::endl;
    std::cout << "To see the integral error contribution, enter 'PI?'" << std::endl;
    std::cout << "To see the derivative error contribution, enter 'PD?'" << std::endl;
    while(true)
    {
        auto line=std::string();
        std::getline(std::cin,line);
        if(line.empty()) return;

        if(line=="R")
        {
            controller.ClearAngle();
            continue;
        }

        if(line=="PE?")
        {
            std::cout << controller.ProportionalTerm() << std::endl;
            continue;
        }

        if(line=="PI?")
        {
            std::cout << controller.IntegralTerm() << std::endl;
            continue;
        }

        if(line=="PD?")
        {
            std::cout << controller.DerivativeTerm() << std::endl;
            continue;
        }
        
        if(line=="A?")
        {
            std::cout << "Angle = " << controller.Angle() << " degrees." << std::endl;
            continue;
        }

        if(line=="PID")
        {
            std::cout << "Enter PID values in that order seperated by spaces" << std::endl;
            auto pidLine=std::string();
            std::getline(std::cin,pidLine);
            std::istringstream strm(pidLine);
            double P;
            double I;
            double D;
            strm >> P;
            strm >> I;
            strm >> D;
            controller.P(P);
            controller.I(I);
            controller.D(D);
            continue;
        }

        if(line=="PID?")
        {
            std::cout << controller.P() << " " << controller.I() << " " << controller.D() << std::endl;
            continue;
        }

        if(line=="ON") { controller.On(true); continue; }
        if(line=="OFF")
        {
            controller.On(false);
            controller.MotorPower(0);
            continue;
        }
        if(line=="SETPOINT")
        {
            std::cout << "Enter the setpoint angle in degrees, it may be negative or positive." << std::endl;
            auto setPointLine=std::string();
            std::getline(std::cin,setPointLine);
            auto sp=std::stod(setPointLine);
            controller.SetPoint(sp);
            continue;
        }

        if(line=="SETPOINT?")
        {
            std::cout << controller.SetPoint() << " degrees" << std::endl;
            continue;
        }

        if(line=="ERROR?")
        {
            std::cout << "Following error : " << controller.Error() << " degrees" << std::endl;
            continue;
        }
        
        if(!controller.On())
        {
            try
            {
                auto val=std::stod(line);
                controller.MotorPower(val);
            }
            catch(...)
            {
                std::cout << "SYNTAX ERROR" << std::endl;
                continue;
            }
        }
    }
}










// EOF *****************************************************************************************************************
