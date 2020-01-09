#pragma once
#include "OKFPGAModule.h"


/***************************************************************************************************
***************************************************************************************************/
class StepperMotorController
{
public:
    /************************************************************************************************
    Singleton pattern, get the one and only instance of the device
    ************************************************************************************************/
    static StepperMotorController& Instance(const OKFPGAModule& device,bool halfStepActive=false)
    {
        static StepperMotorController theInstance(device,halfStepActive);
        return theInstance;
    }

    /************************************************************************************************
    ************************************************************************************************/
    void Enable(bool state) { SetHighWordDiscreteState(state,BitNumberEnable); }
    void Direction(bool state) { SetHighWordDiscreteState(state,BitNumberDirection); }
    void Continuous(bool state) { SetHighWordDiscreteState(state,BitNumberContinuous); }
    bool Enabled() const { return (pulsesPerMicroSecondHiWord&(1<<BitNumberEnable))!=0; }
    bool Direction() const { return (pulsesPerMicroSecondHiWord&(1<<BitNumberDirection))!=0;}
    bool Continous() const { return (pulsesPerMicroSecondHiWord&(1<<BitNumberContinuous))!=0;}
    bool IsMoving() const
    {
        const auto wireOut=m_device.GetWireOut(0x00,true);
        return (wireOut&1)==0;
    }

    /************************************************************************************************
    ************************************************************************************************/
    void SetSpeed(double speedInDegreesPerSecond)
    {
        const double DegreesPerRevolution=360.0;
        const double PulsesPerDegree=StepValue()*PulsesPerRevolution/DegreesPerRevolution;
        const double MircosecondsPerSecond=1e6;
        const double DegreesPerMicrosecond=speedInDegreesPerSecond/MircosecondsPerSecond;
        const double PulsesPerMicrosecond=PulsesPerDegree*DegreesPerMicrosecond;
        const double MicroSecondsPerPulse=1.0/PulsesPerMicrosecond;
        const auto discreteMicroSecondsPerPulse=static_cast<unsigned int>(MicroSecondsPerPulse);
        pulsesPerMicroSecondLowWord=0xFFFF&discreteMicroSecondsPerPulse;
        pulsesPerMicroSecondHiWord&=0xF000;
        pulsesPerMicroSecondHiWord|=(discreteMicroSecondsPerPulse>>16)&0xF;
        m_device.SetWireIn(wireInMicrosecondsBetweenPulsesLoWord,pulsesPerMicroSecondLowWord);
        m_device.SetWireIn(wireInMicrosecondsBetweenPulsesHiWord,pulsesPerMicroSecondHiWord);
        m_device.UpdateWireIns();
    }

    /************************************************************************************************
    ************************************************************************************************/
    void Move(double angleInDegrees)
    {
        const double DegreesPerRevolution=360.0;
        const double PulsesPerDegree=StepValue()*PulsesPerRevolution/DegreesPerRevolution;
        const double pulses=angleInDegrees*PulsesPerDegree;
        const auto discretePulseCount=static_cast<unsigned short>(pulses);
        m_device.SetWireIn(wireInPulsesToMoveIndex,discretePulseCount);
        m_device.UpdateWireIns();
        m_device.ActivateTriggerIn(0x00,0); // Start the move
    }

private:
    /************************************************************************************************
    The logic for setting the three upper running state are the same
    ************************************************************************************************/
    void SetHighWordDiscreteState(bool state,int bitNumber)
    {
        unsigned short mask=1<<bitNumber;
        if(state)
        {
            pulsesPerMicroSecondHiWord|=mask;
        }
        else
        {
            mask=~mask;
            pulsesPerMicroSecondHiWord&=mask;
        }
        m_device.SetWireIn(wireInMicrosecondsBetweenPulsesHiWord,pulsesPerMicroSecondHiWord);
        m_device.UpdateWireIns();
    }

    double StepValue() const { return halfStepActive?2.0:1.0; }

    /************************************************************************************************
    ************************************************************************************************/
    explicit StepperMotorController(const OKFPGAModule& device,bool hstepActive=false):m_device(device),pulsesPerMicroSecondLowWord(0),
        pulsesPerMicroSecondHiWord(0),halfStepActive(hstepActive)
    {
        SetSpeed(1);    // Speed in degrees per second
        Enable(true);
        Continuous(false);
        Direction(true);
    }

    const OKFPGAModule& m_device;
    unsigned short pulsesPerMicroSecondLowWord;
    unsigned short pulsesPerMicroSecondHiWord;

    const bool halfStepActive;


    static const byte wireInPulsesToMoveIndex=0;
    static const byte wireInMicrosecondsBetweenPulsesLoWord=1;
    static const byte wireInMicrosecondsBetweenPulsesHiWord=2;
    static const int BitNumberEnable=15;
    static const int BitNumberContinuous=14;
    static const int BitNumberDirection=13;
    constexpr static const double PulsesPerRevolution=513.024;
};


// EOF *********************************************************************************************
