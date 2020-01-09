/**************************************************************************************************
**************************************************************************************************/
#pragma once
#include "OneWire.h"


class Temperature_Sensor_1WIRE_MAX31820:public OneWire
{
public:
    Temperature_Sensor_1WIRE_MAX31820(const OKFPGAModule& device):OneWire(device){}
    
    /**********************************************************************************************
    Start a temperature reading.  It can take up to 750ms for a temperature reading to occur.
    Based on the accuracy determined by the temperature sensor configuration register.
    By default the configuration register is set for maximum resolution, thus it takes the longes
    to take a reading.
    **********************************************************************************************/
    void StartATemperatureReading() const
    {
        const auto instructions=std::vector<unsigned short>({CmdReset,CmdRomMatch,CmdConvertT});
        SendTransaction(instructions,0);
    }

    /**********************************************************************************************
    After a temperature reading has been initiated, this function may be called repeatedly, looking
    for when the temperature reading is ready.
    **********************************************************************************************/
    bool TemperatureReadingReady() const
    {
        const auto instructions=std::vector<unsigned short>({ CmdRead });
        const auto response=SendTransaction(instructions,1);
        return response[0]==0x00FF;
    }

    /**********************************************************************************************
    Reads the 9 byte scratch pad from the device, checks the CRC and then takes the first two
    bytes of the scratch pad (which is the temperature reading) and converts it into a temperature
    in C returning the temperature reading.
    **********************************************************************************************/
    double GetTemperatureReading() const
    {
        auto instructions=std::vector<unsigned short>({ CmdReset,CmdRomMatch,CmdReadScratchPad });
        instructions.insert(instructions.end(),9,CmdRead);
        const auto feedback=SendTransaction(instructions,9);
        auto byteData=std::vector<byte>();
        std::transform(feedback.begin(),feedback.end(),std::back_inserter(byteData),[](unsigned short x)->byte{return x&0xFF;});
        const auto crc=GetCRC(byteData);

        if(crc!=0)
        {
            throw std::exception("CRC Failure when reading back temperature reading");
        }

        const auto rawReading=short(byteData[1]<<8|byteData[0]);
        const double temperatureInC=rawReading/16.0;
        return temperatureInC;
    }
private:
    static const unsigned short CmdConvertT=0x0044;
    static const unsigned short CmdReadScratchPad=0x00BE;
};

// EOF *********************************************************************************************
