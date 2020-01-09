/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"
#include "Temperature_Sensor_1WIRE_MAX31820.h"
#include <iterator>
#include <fstream>

std::string GetTime();

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    auto sensor=Temperature_Sensor_1WIRE_MAX31820(device);
    const auto deviceID=sensor.ReadDeviceID();
    std::cout << "Device ID: ";
    std::cout << std::fixed << std::hex << std::setfill('0') << std::setw(2);
    std::copy(deviceID.begin(),deviceID.end(),std::ostream_iterator<unsigned short>(std::cout,""));
    std::cout << std::endl;

    // Use the current time to create a unique file name
    auto now=GetTime();
    std::replace(now.begin(),now.end(),'.','_');
    const auto fileName="Tempurature_Log_"+now+".csv";
    auto filestrm=std::ofstream(fileName);
    filestrm << "DATE_TIME,TEMPERATURE IN C,TEMPERATURE IN F" << std::endl;
    auto roundAbout=std::string("|/-\\");
    auto counter=0;
    std::cout << "Data being logged to " << fileName << " file." << std::endl;
    while(true)
    {
        sensor.StartATemperatureReading();
        while(!sensor.TemperatureReadingReady())
        {
            ::Sleep(10);
        }
        counter++;
        counter%=4;
        std::cout << "Temperature data : " << roundAbout[counter] << " : ";
        const auto temperature=sensor.GetTemperatureReading();
        const auto temperatureInF=(9.0*temperature/5.0)+32.0;
        std::cout << std::fixed << std::setprecision(4) << temperature << " C" << " : " << temperatureInF << " F" << "\r";
        filestrm << GetTime() << "," << std::fixed << std::setprecision(4) << temperature << "," << temperatureInF << std::endl;
    }
}


/***********************************************************************************************************************
***********************************************************************************************************************/
std::string GetTime()
{
    auto time=::SYSTEMTIME();
    ::GetLocalTime(&time);
    std::ostringstream stime("");
    stime << std::fixed << std::setfill('0') << std::setw(4) << time.wYear << ".";
    stime << std::fixed << std::setfill('0') << std::setw(2) << time.wMonth << ".";
    stime << std::fixed << std::setfill('0') << std::setw(2) << time.wDay << ".";
    stime << std::fixed << std::setfill('0') << std::setw(2) << time.wHour << ".";
    stime << std::fixed << std::setfill('0') << std::setw(2) << time.wMinute << ".";
    stime << std::fixed << std::setfill('0') << std::setw(2) << time.wSecond << ".";
    stime << std::fixed << std::setfill('0') << std::setw(3) << time.wMilliseconds;
    return stime.str();
}



// EOF *****************************************************************************************************************
