/***************************************************************************************************
Constant speed PID motor controller
***************************************************************************************************/
#pragma once
#include "OKFPGAModule.h"
#include "Averager.h"

class ConstantSpeedPIDControl
{
public:
    /***************************************************************************************************
    ***************************************************************************************************/
    explicit ConstantSpeedPIDControl(const OKFPGAModule& device):m_Device(device)
    {
    }

    /***************************************************************************************************
    ***************************************************************************************************/
    void Update()
    {
        if(On())
        {
            m_Integral+=Error()*I();
            SetMotorPower(ProportionalTerm()+IntegralTerm()+DerivativeTerm());
            m_previousError=Error();
        }
    }

    double SetPoint() const { return m_SetPoint; }
    void SetPoint(double val)
    {
        m_SetPoint=val;
        m_Integral=0;
    }

    double On() const{return m_On;}
    void On(bool val) { m_On=val; m_Integral=0;}
    double P() const { return m_P; }
    void P(double val) { m_P=val; m_Integral=0;}
    double I() const { return m_I; }
    void I(double val) { m_I=val; m_Integral=0;}
    double D() const { return m_D; }
    void D(double val) { m_D=val; m_Integral=0;}

    double Speed() const { return SpeedInDegreesPerSecond(); }
    void MotorPower(double pwr) const { SetMotorPower(pwr); }
    double Error() const { return SetPoint()-Speed();}
    double ProportionalTerm() const {return Error()*P();}
    double IntegralTerm() const { return m_Integral; }
    double DerivativeTerm() const { return (Error()-m_previousError)*D();}

private:
    double m_previousError=0.0;
    double m_Integral=0.0;
    bool m_On=false;

    /***************************************************************************************************
    ***************************************************************************************************/
    double SpeedInDegreesPerSecond() const
    {
        const auto counts=static_cast<short>(m_Device.GetWireOut(0x00,true));
        const auto edgesPerPulse=4.0;
        const auto countsPerRevolution=350.0*edgesPerPulse;
        const auto degreesPerRevolution=360.0;
        const auto secondsPerCount=0.1;
        const auto countsPerSecond=counts/secondsPerCount;
        const auto degreesPerCount=degreesPerRevolution/countsPerRevolution;
        const auto degreesPerSecond=degreesPerCount*countsPerSecond;
        m_Averager.Add(degreesPerSecond);
        return m_Averager.Average();
    }

    /***************************************************************************************************
    ***************************************************************************************************/
    void SetMotorPower(double pwr) const
    {
        pwr=pwr>1?1:pwr;
        pwr=pwr<-1?-1:pwr;
        const double maxPulseCount=16384; // 2^14-1
        const auto pulseCount=pwr*maxPulseCount;
        const auto pulses=static_cast<short>(pulseCount);
        m_Device.SetWireIn(0x00,pulses);
        m_Device.UpdateWireIns();
        m_Device.ActivateTriggerIn(0x00,0);
    }

    mutable Averager m_Averager=Averager(5);
    double m_P=1e-6;
    double m_I=2e-4;
    double m_D=1e-3;
    const OKFPGAModule& m_Device;

    double m_SetPoint=0.0;
};
