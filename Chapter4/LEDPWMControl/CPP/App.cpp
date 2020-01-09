/***********************************************************************************************************************
Application specific file
***********************************************************************************************************************/
#include "OKFPGAModule.h"
#include "KeyBoard.h"
#include <iterator>
#include <iomanip>

/***********************************************************************************************************************
Helper class
***********************************************************************************************************************/
class PWMConsoleControl
{
public:
    /********************************************************************************************************************
    ********************************************************************************************************************/
    static PWMConsoleControl& Inst()
    {
        static PWMConsoleControl retval;
        return retval;
    }

    /********************************************************************************************************************
    ********************************************************************************************************************/
    void Increment()
    {
        if(ActivePWM()==m_pwmMax) return;
        ActivePWM()++;
    }

    /********************************************************************************************************************
    ********************************************************************************************************************/
    void Decrement()
    {
        if(ActivePWM()==0x000) return;
        ActivePWM()--;
    }

    /********************************************************************************************************************
    ********************************************************************************************************************/
    void MoveRight()
    {
        m_selector++;
        m_selector%=8;
    }

    /********************************************************************************************************************
    ********************************************************************************************************************/
    void MoveLeft()
    {
        if(m_selector==0)
        {
            m_selector=7;
        }
        else
        {
            m_selector--;
        }
    }

    /********************************************************************************************************************
    ********************************************************************************************************************/
    operator std::string()
    {
        auto retval=std::ostringstream();
        for(size_t x=0;x<m_PWMs.size();x++)
        {
            retval << PWMAsString(x);
        }
        return retval.str();
    }

    const std::vector<unsigned short>& Data() const { return m_PWMs; }
private:
    std::string PWMAsString(size_t selector)
    {
        auto retval=std::ostringstream();
        retval << (selector==m_selector?" -->":"    ");
        retval << "0x" << std::hex << std::setw(4) << std::setfill('0') << m_PWMs[selector];
        return retval.str();
    }

    unsigned short& ActivePWM(){return m_PWMs[m_selector];}
    PWMConsoleControl():m_PWMs(8,0x000),m_selector(0){}
    const size_t m_pwmMax=0x400;
    std::vector<unsigned short> m_PWMs;
    size_t m_selector;
};

void LEDControl(const OKFPGAModule& device,int key);
void Oozy(const OKFPGAModule& device,int key);

/***********************************************************************************************************************
Our application goes here
***********************************************************************************************************************/
void RunApp(const OKFPGAModule& device)
{
    // Allow the user to control the LED's
    KeyBoard<OKFPGAModule> kb;
    KeyBoard<OKFPGAModule>::ShowConsoleCursor(false);
    std::cout << "Use RIGHT/LEFT keys to select the PWM" << std::endl;
    std::cout << "Use UP/DOWN keys to change the value of the PWM" << std::endl << std::endl;
    kb.InstallKeyHandler(LEDControl);
    kb.RunKeyHandler(device);

    std::cout << std::endl << std::endl;
    std::cout << "OOZIES" << std::endl;
    kb.InstallKeyHandler(Oozy);
    kb.RunKeyHandler(device);
}

/***********************************************************************************************************************
The template application provides control of the LED's via the console
***********************************************************************************************************************/
void LEDControl(const OKFPGAModule& device, const int key)
{
    std::cout << static_cast<std::string>(PWMConsoleControl::Inst()) << "\r";

    if(key==VK_RIGHT)
    {
        PWMConsoleControl::Inst().MoveRight();
    }

    if(key==VK_LEFT)
    {
        PWMConsoleControl::Inst().MoveLeft();
    }

    if(key==VK_UP)
    {
        PWMConsoleControl::Inst().Increment();
    }

    if(key==VK_DOWN)
    {
        PWMConsoleControl::Inst().Decrement();
    }

    // Write the PWM Vals to the pipe
    device.WriteToPipeIn(0x00,PWMConsoleControl::Inst().Data());
}

class OozyIncrementer
{
public:
    OozyIncrementer(unsigned short val):m_val(val){}
    void Next()
    {
        m_val+=dir;
        if(m_val==0x080) dir=-1;
        if(m_val==0x000) dir=1;
    }
    unsigned short Value() const { return m_val; }
private:
    int dir=1;
    unsigned short m_val;
};

/***********************************************************************************************************************
Oozing LED's smoothly for cool effects
***********************************************************************************************************************/
void Oozy(const OKFPGAModule& device,int key)
{
    static std::vector<OozyIncrementer> Oozies({OozyIncrementer(0),
                                                OozyIncrementer(10),
                                                OozyIncrementer(20),
                                                OozyIncrementer(30),
                                                OozyIncrementer(40),
                                                OozyIncrementer(50),
                                                OozyIncrementer(60),
                                                OozyIncrementer(70),
        });

    auto vals=std::vector<unsigned short>();
    for (auto& Oozie : Oozies)
    {
        vals.push_back(Oozie.Value());
        Oozie.Next();
    }

    device.WriteToPipeIn(0x00,vals);
}



// EOF *****************************************************************************************************************
