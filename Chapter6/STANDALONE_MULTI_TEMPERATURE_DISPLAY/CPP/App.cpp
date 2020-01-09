/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"
#include <iomanip>
#include <numeric>

void DisplayTemperatures(const OKFPGAModule& device,int key);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    KeyBoard<OKFPGAModule> kb;
    KeyBoard<OKFPGAModule>::ShowConsoleCursor(false);
    kb.InstallKeyHandler(DisplayTemperatures);
    kb.RunKeyHandler(device);
}

/***********************************************************************************************************************
The template application provides control of the LED's via the console
***********************************************************************************************************************/
void DisplayTemperatures(const OKFPGAModule& device, const int key)
{
    // Get the temperature from the chip dedicated to that purpose
    auto reading=device.GetWireOut(0x00,true);
    reading&=0xFFF;
    const double readingInForC=reading/16.0;

    // Get the temperature reading from the ADC/Thermistor Circuit, we will need to use averaging due to the noise
    const size_t numberOfPointsToAverage=20;
    static std::vector<unsigned short> data(numberOfPointsToAverage,0);
    static size_t next=0;
    
    // Start the ADC conversion
    device.ActivateTriggerIn(0x00,0);
    unsigned short adc_raw;

    // Wait for it to complete
    while(true)
    {
        adc_raw=device.GetWireOut(0x01,true);
        if((adc_raw&0x8000)!=0) break;
    }

    // Mask out the finished bit
    adc_raw&=0x3FF;

    // Add data element to the averager
    data[next]=adc_raw;
    if(next==data.size()-1)
    {
        next=0;
    }
    else
    {
        next++;
    }

    // Get the average raw adc reading, because we are using the 3.3V digital power to power
    // the analog portion of the circuit, the output contains a lot of noise so we must
    // average this out for a stable reading
    const auto average_adc_raw=std::accumulate(data.begin(),data.end(),0)/data.size();

    // The reference is 2.5V, the number of step is 2^9-1=1023
    const double voltsPerBit=2.5/1023;

    // Convert the raw ADC reading into a voltage
    const double voltage=average_adc_raw*voltsPerBit;

    // The thermistor is non linear, I generated this polynomial from excel, in excel we first had
    // to use the formula from the datasheet involviing co-efficiens A1,A2,A3 and A4
    // let Rn=R/Rref, where Rref=10K for our thermistor
    // then T(r)=1/( A1 + B1*ln(Rn) + C1*ln(Rn)^2 + D1*ln(Rn)^3 ) in Kelvin
    // and converted this to C by C=Tk-273.15
    // After this from the schematic for the amplifier we have to convert this to a voltage:
    // where, the voltage for the 27K divider with the thermistor is:
    // 3.3V * Rth /(Rth+24e3) let this equal Vd for divider voltage then the final output voltage is
    // 2.38 * (1.65-Vd)
    // From this I plotted the voltage vs output temperature in C in excel, being that it was 
    // non linear, I curve fitted it using excel that gave the 3rd degree polynomial:
    // T(v)=0.8612*v^3 - 0.7024v^2 +14.024v-3.3573
    double temperature=0.8612*voltage*voltage*voltage-0.7024*voltage*voltage+14.024*voltage-3.3532;

    // Because the tolerance on the Resistors is not tight (+/-5-10%) we had to adjust this  based on 
    // a constant co-effiecient that will be different in your ciruit
    temperature*=1.05;   // Change this so the thermistor temperature closely matches the 1Wire temperature

    // Convert to degrees F
    temperature*=9.0/5.0;
    temperature+=32;

    std::cout << std::fixed << std::setprecision(2) << std::setw(3) << "device temp: " << readingInForC << "  | adc thermistor temp: " << temperature << '\r';
}


// EOF *****************************************************************************************************************
