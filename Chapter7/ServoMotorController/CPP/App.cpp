/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include <iostream>

short ConvertDegreesToFixedPoint(double degrees);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    std::cout << "Enter an angle between -60.0 and +60.0 degrees" << std::endl;
    std::cout << "The motor will move to the commanded angle and then display feedback angle" << std::endl;
    std::cout << "Enter nothing to quit" << std::endl;

    while(true)
    {
        // Read a line of text
        std::string line;
        std::getline(std::cin,line);
        
        // If the line is empty the user wants to quit
        if(line.empty()) break;

        // Convert the line into a double, convert that to fixed point S7.8
        // Send the command for the motor to move to that angle
        const double conversion=atof(line.c_str());
        const auto commandValue=ConvertDegreesToFixedPoint(conversion);
        device.SetWireIn(0x00,commandValue);
        device.UpdateWireIns();
        device.ActivateTriggerIn(0x00,0);

        ::Sleep(1500);  // Give motor time to stabalize at the new point

        device.ActivateTriggerIn(0x00,1);   // If we read the ADC at this point, we get the previous measurement

        unsigned short adc_counts;
        auto previousMeasurement=true;
        while(true)
        {
            adc_counts=device.GetWireOut(0x00,true);
            if((adc_counts&0x8000)!=0)  // The measurement is done, when bit 15 is one
            {
                // We have the previous measurement, so we must do it again to get the current measurement
                if(previousMeasurement)
                {
                    previousMeasurement=false;
                    device.ActivateTriggerIn(0x00,1);   // Get new measurement
                }
                else
                {
                    break;
                }
            }
        }
        adc_counts&=0x7FFF; // mask out done bit
        double degrees=adc_counts-628;  // constant is center point
        
        // I have found the constants for degrees per count is slightly
        // different for positive angles vs negative angles
        if(degrees>0)
        {
            degrees*=0.272727;  // degrees per count when positive
        }
        else
        {
            degrees*=0.254237;  // degrees per count when negative
        }
        
        std::cout << degrees << std::endl;
    }
}

/***********************************************************************************************************************
Convert a double to signed fixed point S7.8
***********************************************************************************************************************/
short ConvertDegreesToFixedPoint(double degrees)
{
    // determine if it is a negative number
    const auto isNegative=degrees<0.0;
    
    // the conversion must have a positive number
    degrees=abs(degrees);
    
    // left of decimal point is determined by stripping of the non whole number by converting to an integer type
    const auto leftOfDecimalPlace=static_cast<unsigned short>(degrees);

    // The fraction is just the angle minus the whole part
    double frac=degrees-leftOfDecimalPlace;

    // we will parse the portion frac into an equivalent binary fraction
    double fraction=0.5;
    
    // There are 8 bits in the fraction we will build them up in pieces
    byte parts=0;

    // go through all 8 fractional parts setting bits high or low as needed
    for(auto x=0;x<8;x++)
    {
        // Make room for the next bit
        parts<<=1;
        
        // if the frac is greater than the current fraction for the specified position
        if(frac>=fraction)
        {
            // The bit goes to one
            parts|=1;

            // the remaining fraction must subtract out the fraction for the specified position
            frac-=fraction;
        }
        fraction*=0.5;  // The next binary fraction bit will always be 1/2 the previous
    }

    // Combine the whole number part back with the fraction
    unsigned short result=leftOfDecimalPlace<<8|parts;

    // If the original number was negative take the two's complement of the result
    // to restore the negative number, two's compliment is just invert all bits and add 1
    if(isNegative)
    {
        result=~result;
        result++;
    }

    return result;
}

// EOF *****************************************************************************************************************
