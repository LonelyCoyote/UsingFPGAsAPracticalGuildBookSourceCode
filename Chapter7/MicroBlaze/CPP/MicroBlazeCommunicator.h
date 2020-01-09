/***********************************************************************************************
Allows for communication with the micorblaze over the IO bus per firmware specification
***********************************************************************************************/
#pragma once
#include "OKFPGAModule.h"

class MicroBlazeCommnicator
{
public:
    MicroBlazeCommnicator(const OKFPGAModule& device):m_device(device){}

    /***********************************************************************************************
    ***********************************************************************************************/
    void WriteCommand(const std::string& cmd) const
    {
        auto writeData=std::vector<unsigned short>();
        bool phase=true;
        unsigned short item=0;
        for (auto c : cmd)
        {
            if(phase)
            {
                item=c;
                phase=false;
            }
            else
            {
                item|=(c<<8);
                writeData.push_back(item);
                phase=true;
            }
        }
        if(phase)
        {
            writeData.push_back(0x0000);    // came out even must add null termination
        }
        else
        {
            writeData.push_back(item);      // came out odd add the last item
        }
        m_device.WriteToPipeIn(0x00,writeData);
    }

    /***********************************************************************************************
    Get Response (note this is blocking!  It will wait forever for a response)
    ***********************************************************************************************/
    std::string GetResponse() const
    {
        std::string response;
        while(true)
        {
            unsigned short count;
            while(true)
            {
                count=m_device.GetWireOut(0x00,true);
                if(count>0) break;
                ::Sleep(10);
            }
            auto data=m_device.ReadFromPipeOut(0x00,count);
            for (auto item:data)
            {
                const char lower=item&0xFF;
                const char upper=(item>>8)&0xFF;
                if(lower==0) return response;
                response.push_back(lower);
                if(upper==0) return response;
                response.push_back(upper);
            }
        }
    }

private:
    const OKFPGAModule& m_device;
};
















// EOF *****************************************************************************************

