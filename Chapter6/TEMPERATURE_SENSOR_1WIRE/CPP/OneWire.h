/**************************************************************************************************
Base class for all one wire devices, performs basic one wire operations.
The class is meant to be a base class for a specific one wire device.
**************************************************************************************************/
#pragma once
#include "OKFPGAModule.h"
#include <vector>
#include <algorithm>
#include <iomanip>

class OneWire
{
public:
    /*******************************************************************************************************************
    Reads back the device ID using the Read Device ID ROM command.
    Warning: This will only work if there is just ONE device on the bus!
    *******************************************************************************************************************/
    std::vector<byte> ReadDeviceID() const
    {
        const auto instructions=std::vector<unsigned short>({ CmdReset,CmdReadDeviceID });
        const auto data=SendTransaction(instructions,8);
        auto byte_data=std::vector<byte>();
        std::transform(data.begin(),data.end(),std::back_inserter(byte_data),[](unsigned short x)-> byte {return x&0xFF; });
        const auto crcCheck=GetCRC(byte_data);
        if(crcCheck!=0)
        {
            std::ostringstream strm;
            strm << "ID CRC Failure, CRC Failed Value is: 0x" << std::hex << std::fixed << std::setfill('0') << crcCheck;
            throw std::exception(strm.str().c_str());
        }
        return byte_data;
    }

    /*******************************************************************************************************************
    If you know the device ID of the device you want to talk to you can set it using this prior to any communication
    to the device.  The device ID is 8 bytes long, the upper 8 bits of each word should be logic low.  The device ID
    must be 8 words long, but only the first 8 bits of each word is used for the ID.  Also the Device ID needs to be
    sent in LSB first moving to MSB last
    *******************************************************************************************************************/
    void SetDeviceID(std::vector<unsigned short> deviceID) const
    {
        if(deviceID.size()!=8)
        {
            throw std::exception("When setting the device ID you must pass in 8 unsigned short values!");
        }

        std::transform(deviceID.begin(),deviceID.end(),deviceID.begin(),[](unsigned short x)->unsigned short {return x&0xFF; });

        auto instructions=std::vector<unsigned short>({ CmdSetDeviceID });
        instructions.insert(instructions.end(),deviceID.begin(),deviceID.end());
        SendTransaction(instructions,0);
    }

protected:
    /**********************************************************************************************
    Constructor, can only be called from a derived class
    **********************************************************************************************/
    explicit OneWire(const OKFPGAModule& device):m_Device(device){}


    /**********************************************************************************************
    Performs a transaction on the one wire bus
    data: the instructions/data for the transaction
    byteCountFromDevice: The number of bytes expected back from the transaction
    **********************************************************************************************/
    std::vector<unsigned short> SendTransaction(const std::vector<unsigned short>& data,size_t byteCountFromDevice) const
    {
        m_Device.WriteToPipeIn(0x00,data);
        m_Device.ActivateTriggerIn(0x00,0);
        while(true)
        {
            const auto chkForDone=m_Device.GetWireOut(0x00,true);
            if(chkForDone&TransactionCompleted) break;
        }

        if(byteCountFromDevice==0) return std::vector<unsigned short>();

        auto retval=m_Device.ReadFromPipeOut(0x00,byteCountFromDevice);

        return retval;
    }

    /*******************************************************************************************************************
    Polynomial: x8+x5+x4+1
    *******************************************************************************************************************/
    static byte GetCRC(const std::vector<byte>& data)
    {
        auto s1=false;
        auto s2=false;
        auto s3=false;
        auto s4=false;
        auto s5=false;
        auto s6=false;
        auto s7=false;
        auto s8=false;
        for(auto x : data)
        {
            for(auto bit=0; bit<8; bit++)
            {
                const auto bitIn=(x &(1<<bit))!=0;
                const auto feedback=bitIn!=s8;
                s8=s7;
                s7=s6;
                s6=s5!=feedback;
                s5=s4!=feedback;
                s4=s3;
                s3=s2;
                s2=s1;
                s1=feedback;
            }
        }

        const auto retval=(s1?1:0)<<7|(s2?1:0)<<6|(s3?1:0)<<5|(s4?1:0)<<4|(s5?1:0)<<3|(s6?1:0)<<2|(s7?1:0)<<1|(s8?1:0);
        return retval;
    }

    static const unsigned short CmdRead=1<<8;
    static const unsigned short CmdReset=1<<9;
    static const unsigned short CmdRomMatch=1<<10;
    static const unsigned short CmdRomResume=1<<11;
    static const unsigned short CmdRomSkip=1<<12;
    static const unsigned short CmdReadDeviceID=1<<13;
    static const unsigned short CmdSetDeviceID=1<<14;

private:
    const OKFPGAModule& m_Device;
    static const unsigned short TransactionCompleted=1<<2;
};

// EOF *********************************************************************************************
