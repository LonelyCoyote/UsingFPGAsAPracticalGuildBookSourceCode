/***********************************************************************************************************************
A simplified inline wrapper for the okFrontPanel.dll intended for use with the book:
Using FPGA Modules, a Practical Guide
Author: Dennis Bingaman

This is specifically for USB 2.0 devices and not intended for USB 3.0 devices!
***********************************************************************************************************************/
#ifndef OKFPGAMODULE_H
#define OKFPGAMODULE_H
#pragma warning(push)
#pragma warning(disable:4267)	// ignore conversion warning from size_t to unsigned int in vendor library
#include "okFrontPanelDLL.h"
#pragma warning(pop)
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>


class OKFPGAModule
{
public:
	/*******************************************************************************************************************
	Constructor
	*******************************************************************************************************************/
	explicit OKFPGAModule(const std::string& bitFileName="TopLevel.bit"):
        m_BitFileName(bitFileName),
        m_hDevice(okFrontPanel_Construct())
	{
		const auto devCount = okFrontPanel_GetDeviceCount(m_hDevice);
		if(devCount!=1)
		{
			auto err = std::ostringstream();
			err << "Expected to find one Opal Kelly FPGA module connected to the computer USB port, actually found: " << devCount;
			throw std::exception(err.str().c_str());
		}
		CheckForError(okFrontPanel_OpenBySerial(m_hDevice, ""),"okFrontPanel_OpenBySerial");
		
        if(!m_BitFileName.empty())
        {
            CheckForError(okFrontPanel_ConfigureFPGA(m_hDevice,m_BitFileName.c_str()),"okFrontPanel_ConfigureFPGA");
        }
		
	    okFrontPanel_UpdateWireIns(m_hDevice);
	}

	/*******************************************************************************************************************
	Destructor
	*******************************************************************************************************************/
	virtual ~OKFPGAModule()
	{
		okFrontPanel_Destruct(m_hDevice);
	}

	/*******************************************************************************************************************
	Set a wire in
	rep: The relative end point valid values are (0-31), this handles adding the offset for you
	val: The value to set it for
	mask: Which bits of the wire in to change within val, default is all of them
	update: default false, set true if you want to update all wire in's
	*******************************************************************************************************************/
	void SetWireIn(byte rep,unsigned short val,unsigned short mask=0xFFFF,bool update=false) const
	{
		CheckForError(okFrontPanel_SetWireInValue(m_hDevice, BaseAddressWireIn+rep,val, mask),"okFrontPanel_SetWireInValue");
		if(!update) return;
		okFrontPanel_UpdateWireIns(m_hDevice);
	}

	/*******************************************************************************************************************
	Set a specific bit on a wire in high or low (true or false)
	rep: The relative end point valid values are (0-31), this handles adding the offset for you
	bitNumber: the bit number to set high or low (0 to 15)
	state: true to set the bit high, false to set the bit low
    update: updates wire ins, default is false
	*******************************************************************************************************************/
	void SetWireInBit(byte rep,byte bitNumber,bool state,bool update=false) const
	{
	    const unsigned short mask=1<<bitNumber;
	    const unsigned short val=state?0xFFFF:0x0000;
        SetWireIn(rep,val,mask,update);
	}

	/*******************************************************************************************************************
	Update the wire ins
	*******************************************************************************************************************/
	void UpdateWireIns() const
	{
		okFrontPanel_UpdateWireIns(m_hDevice);
	}

	/*******************************************************************************************************************
	Get a wire out value
	rep: The relative end point valid values are (0-31), this handles adding the offset for you
	*******************************************************************************************************************/
	unsigned short GetWireOut(byte rep,bool update=false) const
	{
		if(update)
		{
			okFrontPanel_UpdateWireOuts(m_hDevice);
		}
		
		const auto retval=static_cast<unsigned short>(okFrontPanel_GetWireOutValue(m_hDevice, BaseAddressWireOut + rep));
        return retval;
	}

    /*******************************************************************************************************************
    Returns the status of a specific bit for a wire out end point true for bit high, false for bit low
    rep: The relative end point valid values are (0-31), this handles adding the offset for you
    bitNumber: the bit number to check
    update: default false, will update the wire outs prior to getting the wire out bit state when true
    *******************************************************************************************************************/
    bool GetWireOutBit(byte rep,byte bitNumber,bool update=false) const
	{
        const auto val=GetWireOut(rep,update);
        const auto mask=1<<bitNumber;
        return (val&mask)!=0;
	}

	/*******************************************************************************************************************
	Update the wire outs
	*******************************************************************************************************************/
	void UpdateWireOuts() const
	{
		okFrontPanel_UpdateWireOuts(m_hDevice);
	}

    /*******************************************************************************************************************
    Set a trigger in for a given end point
    rep: The relative end point valid values are (0-31), this handles adding the offset for you
    bitNumber: The bit within the end point to trigger (0-15)
    *******************************************************************************************************************/
    void ActivateTriggerIn(byte rep,byte bitNumber) const
	{
        CheckForError(okFrontPanel_ActivateTriggerIn(m_hDevice,BaseAddressTriggerIn+rep,bitNumber),"okFrontPanel_ActivateTriggerIn");
	}

    /*******************************************************************************************************************
    Returns true if a given set of trigger outs has been triggered
    rep: The relative end point valid values are (0-31), this handles adding the offset for you
    mask: the bits within the mask that are logic 1 determine which bits to check for a trigger on
    update: determines if you should update the trigger outs when checking them, default is false
    *******************************************************************************************************************/
    bool IsTriggered(byte rep,byte mask,bool update=false) const
	{
        if(update)
        {
            UpdateTriggerOuts();
        }
	    return okFrontPanel_IsTriggered(m_hDevice,BaseAddressTriggerOut+rep,mask);
	}

    /*******************************************************************************************************************
    Updates all trigger outs
    *******************************************************************************************************************/
    void UpdateTriggerOuts() const
	{
        okFrontPanel_UpdateTriggerOuts(m_hDevice);
	}

    /*******************************************************************************************************************
    Writes data to a pipe in
    rep: The relative end point valid values are (0-31), this handles adding the offset for you
    data: The data to write
    *******************************************************************************************************************/
    void WriteToPipeIn(byte rep,const std::vector<unsigned short>& data) const
	{
	    // We need to convert the vector data into the C equivalent of unsigned char*
	    const auto dataHolder=std::for_each(data.begin(),data.end(),ConvertDataFromVectorToCharBuffer(data.size()));
	    const auto bytesToWrite=data.size()*2;
	    const auto written=okFrontPanel_WriteToPipeIn(m_hDevice,BaseAddressPipeIn+rep,static_cast<long>(bytesToWrite),dataHolder.Buffer());
	    dataHolder.Free();
	    if(written<0)
        {
            auto msg=std::ostringstream();
            msg << "okFrontPanel_WriteToPipeIn failed, error is: " << GetErrorMessage(static_cast<ok_ErrorCode>(written));
	        throw std::exception(msg.str().c_str());
        }
        if(bytesToWrite!=static_cast<const unsigned int>(written))
        {
            auto msg=std::ostringstream();
            msg << "Write to pipe was suppose to write " << bytesToWrite << " bytes but actually wrote " << written << " bytes.";
            throw std::exception(msg.str().c_str());
        }
    }

    /*******************************************************************************************************************
    Writes data to a pipe in
    rep: The relative end point valid values are (0-31), this handles adding the offset for you
    len: The number of items you want to read from the pipe out 
    Returns with the pipe out data
    *******************************************************************************************************************/
    std::vector<unsigned short> ReadFromPipeOut(byte rep,size_t len) const
	{
	    const auto buffer=new unsigned char[len*2];
        const auto read=okFrontPanel_ReadFromPipeOut(m_hDevice,BaseAddressPipeOut+rep,static_cast<long>(len*2),buffer);
        const auto pData=reinterpret_cast<unsigned short*>(buffer);
        const auto retval=std::vector<unsigned short>(pData,pData+len);
        if(read<0)
        {
            auto msg=std::ostringstream();
            msg<<"okFrontPanel_ReadFromPipeOut failed, error is: "<<GetErrorMessage(static_cast<ok_ErrorCode>(read));
            throw std::exception(msg.str().c_str());
        }
        if(static_cast<size_t>(read)!=(len*2))
        {
            auto msg=std::ostringstream();
            msg<<"Read from pipe was suppose to read "<<len*2<<" bytes but actually read "<<read<<" bytes.";
            throw std::exception(msg.str().c_str());
        }
        return retval;
	}

private:
    // This is a singleton, you are not allowed to create a copy
    OKFPGAModule(const OKFPGAModule& cpy);

    /*******************************************************************************************************************
    Functor for use in converting a vector of unsigned short into a unsigned char* buffer
    *******************************************************************************************************************/
    struct ConvertDataFromVectorToCharBuffer
    {
        ConvertDataFromVectorToCharBuffer(size_t len):buffer(new unsigned char[len*2]){pos=buffer;}

        void operator()(unsigned short item)
        {
            *pos=static_cast<unsigned char>(item&0xFF);
            pos++;
            *pos=static_cast<unsigned char>(item>>8);
            pos++;
        }

        void Free() const { delete[] buffer; }

        unsigned char* Buffer() const {return buffer;}
    private:
        unsigned char* pos;
        unsigned char* const buffer;
    };

    const std::string m_BitFileName;
    void* const m_hDevice;
	static const byte BaseAddressWireIn = 0x00;
	static const byte BaseAddressWireOut = 0x20;
	static const byte BaseAddressTriggerIn = 0x40;
	static const byte BaseAddressTriggerOut = 0x60;
	static const byte BaseAddressPipeIn = 0x80;
	static const byte BaseAddressPipeOut = 0xA0;

	/*******************************************************************************************************************
	Check for an error based on an error code, if an error occurred throw an exception with a message on who caused
	the error (the functionCalled name) and the error message
	ec: The error code returned from the function call
	functionCalled: The name of the function that was called
	*******************************************************************************************************************/
	static void CheckForError(const ok_ErrorCode ec,const std::string& functionCalled)
	{
		if(ec==ok_NoError) return;
		const auto errorMessage = GetErrorMessage(ec);
		auto message = std::ostringstream("");
		message << "Error in call to '" << functionCalled << "' error is: " << errorMessage;
		throw std::exception(message.str().c_str());
	}

	/*******************************************************************************************************************
	Return an error message from an error code
	*******************************************************************************************************************/
	static std::string GetErrorMessage(const ok_ErrorCode ec)
	{
		const auto bufferLen = okFrontPanel_GetErrorString(ec, nullptr, 0);
		const auto bp = new char[bufferLen + 1];
		okFrontPanel_GetErrorString(ec, bp, bufferLen + 1);
		const std::string errMsg(bp);
		delete[] bp;
		return errMsg;
	}
};

#endif

// EOF *****************************************************************************************************************
