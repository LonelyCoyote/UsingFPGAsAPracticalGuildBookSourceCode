/**********************************************************************************************************************
Provides read and write capability to the DS24B33 EEPROM
This is an inline module and uses the 'singleton' pattern.  We will only be ever using one of these devices on a bus
at a time for all the experiments in the book
Author: Dennis Bingaman
**********************************************************************************************************************/
#pragma once
#include "OKFPGAModule.h"
#include <string>
#include <vector>
#include <algorithm>
#include <iomanip>

class EEPROM_1WIRE_DS24B33
{
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


    explicit EEPROM_1WIRE_DS24B33(const OKFPGAModule& device):m_Device(device) {}

    const OKFPGAModule& m_Device;
    static const unsigned short EEPROMCmdWriteScratchPad=0x000F;
    static const unsigned short EEPROMCmdReadScratchPad=0x00AA;
    static const unsigned short EEPROMCmdCopyScratchPad=0x0055;
    static const unsigned short EEPROMCmdReadMemory=0x00F0;

    static const unsigned short CmdRead=1<<8;
    static const unsigned short CmdReset=1<<9;
    static const unsigned short CmdRomMatch=1<<10;
    static const unsigned short CmdRomResume=1<<11;
    static const unsigned short CmdRomSkip=1<<12;
    static const unsigned short CmdReadDeviceID=1<<13;
    static const unsigned short CmdSetDeviceID=1<<14;
    static const unsigned short TransactionCompleted=1<<2;

    struct ConvertToByte
    {
        byte operator()(unsigned short item) const
        {
            item&=0xFF;
            const auto retval=static_cast<byte>(item);
            return retval;
        }
    };

    /*******************************************************************************************************************
    Polynomial: x8+x5+x4+1
    *******************************************************************************************************************/
    static byte GetCRCOfID(const std::vector<byte>& data)
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

public:
    /*******************************************************************************************************************
    Returns the one and only instance of this class using the singleton pattern
    *******************************************************************************************************************/
    static std::shared_ptr<EEPROM_1WIRE_DS24B33>& GetInstance(const OKFPGAModule& device)
    {
        static std::shared_ptr<EEPROM_1WIRE_DS24B33> retval(nullptr);
        if(retval!=nullptr) return retval;
        retval=std::make_shared<EEPROM_1WIRE_DS24B33>(EEPROM_1WIRE_DS24B33(device));
        return retval;
    }

    /*******************************************************************************************************************
    Reads back the device ID using the Read Device ID ROM command.
    Warning: This will only work if there is just ONE device on the bus!
    *******************************************************************************************************************/
    std::vector<byte> ReadDeviceID() const
    {
        const auto instructions=std::vector<unsigned short>({ CmdReset,CmdReadDeviceID });
        const auto data=SendTransaction(instructions,8);
        auto byte_data=std::vector<byte>();
        std::transform(data.begin(),data.end(),std::back_inserter(byte_data),ConvertToByte());
        const auto crcCheck=GetCRCOfID(byte_data);
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

    /*******************************************************************************************************************
    Write a specified number of bytes to memory.  Only the lower 8 bits of each word is used for the programming.
    Be sure to stay within the 'page' or the instruction will fail.
    For example, each page is 32 bytes long, so if you want to write to an entire page it must start on a page boundary
    for example the second page would start at 0x20.  You may write within a page it is just the number of bytes
    writeen must not exceed the page boundary when starting at a posisiton not on a page boundary.

    address: the address where the write will start
    data: all the data you want to write, each word is considered one byte because it only looks at the lower 8 bits
    *******************************************************************************************************************/
    void WriteToMemory(unsigned short address,std::vector<unsigned short>& data) const
    {
        const unsigned short TA1=address&0xff;
        const unsigned short TA2=address>>8;
        std::transform(data.begin(),data.end(),data.begin(),[](unsigned short x)->unsigned short {return x&0xFF; });

        // Write the data to the scratch pad
        auto instructions=std::vector<unsigned short>({ CmdReset,CmdRomMatch,EEPROMCmdWriteScratchPad,TA1,TA2 });
        instructions.insert(instructions.end(),data.begin(),data.end());
        SendTransaction(instructions,0);

        // Read the data back from the scratch pad
        instructions.assign({ CmdReset,CmdRomMatch,EEPROMCmdReadScratchPad,CmdRead,CmdRead,CmdRead });
        instructions.insert(instructions.end(),data.size(),CmdRead);
        const auto readBack=SendTransaction(instructions,data.size()+3);

        // Write the scratch pad to the memory, allow this up to 5ms to actually program the device
        instructions.assign({ CmdReset,CmdRomMatch,EEPROMCmdCopyScratchPad });
        instructions.insert(instructions.end(),readBack.begin(),readBack.end());
        SendTransaction(instructions,0);

        ::Sleep(5); // it takes the EEPROM a maximum of 5 ms to program the EEPROM

        // Read the data from the memory
        instructions.assign({ CmdReset,CmdRomMatch,EEPROMCmdReadMemory,TA1,TA2 });
        instructions.insert(instructions.end(),data.size(),CmdRead);
        const auto verify=SendTransaction(instructions,data.size());

        if(data!=verify)
        {
            throw std::exception("Data written to memory did not match data sent");
        }
    }

    /*******************************************************************************************************************
    Read a number of bytes from memory

    address: the address to read from
    byteCount: the number of bytes you want to read, there are no page boundary limits on a read, you may read the
    entire contents of the EEPROM if you want to.  Again each byte is stored in a word and only the lower 8 bits are used.
    *******************************************************************************************************************/
    std::vector<unsigned short> ReadFromMemory(unsigned short address,int byteCount) const
    {
        const unsigned short TA1=address&0xff;
        const unsigned short TA2=address>>8;

        if(byteCount<=0) return std::vector<unsigned short>();
        // Read the data from the memory
        auto instructions=std::vector<unsigned short>({ CmdReset,CmdRomMatch,EEPROMCmdReadMemory,TA1,TA2 });
        instructions.insert(instructions.end(),byteCount,CmdRead);
        const auto retval=SendTransaction(instructions,byteCount);

        return retval;
    }
};

// EOF *****************************************************************************************************************



