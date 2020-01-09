/**********************************************************************************************************************
Provides read and write capability to the DS24B33 EEPROM
This is an inline module and uses the 'singleton' pattern.  We will only be ever using one of these devices on a bus
at a time for all the experiments in the book
Author: Dennis Bingaman
**********************************************************************************************************************/
#pragma once
#include "OneWire.h"
#include <vector>
#include <algorithm>
#include <iomanip>

class EEPROM_1WIRE_DS24B33: public OneWire
{
    explicit EEPROM_1WIRE_DS24B33(const OKFPGAModule& device):OneWire(device) {}

    static const unsigned short EEPROMCmdWriteScratchPad=0x000F;
    static const unsigned short EEPROMCmdReadScratchPad=0x00AA;
    static const unsigned short EEPROMCmdCopyScratchPad=0x0055;
    static const unsigned short EEPROMCmdReadMemory=0x00F0;

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



