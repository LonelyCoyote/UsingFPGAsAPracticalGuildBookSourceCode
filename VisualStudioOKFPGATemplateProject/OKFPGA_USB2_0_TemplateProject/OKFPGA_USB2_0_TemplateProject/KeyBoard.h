/***********************************************************************************************************************
Helper class for detecting keyboard input on a Windows machine.
***********************************************************************************************************************/
#ifndef KEYBOARD_H
#define KEYBOARD_H
#include <Windows.h>
#include <iostream>

template<typename T> class KeyBoard
{
public:
    typedef void(*KEY_HANDLER_FUNC)(const T&,int);
    KeyBoard():m_KeyHandlerFunc(nullptr),m_Handle(::GetStdHandle(STD_INPUT_HANDLE)),m_SleepTimeBetweenCalls(20) {}
    
    /*******************************************************************************************************************
    Return the last key that was pressed or less than zero if no key was pressed
    *******************************************************************************************************************/
    int LastKeyPressed() const
    {
        ::DWORD events=0;
        ::GetNumberOfConsoleInputEvents(m_Handle,&events);
        if(events==0) return -1;    // No keyboard events
        ::INPUT_RECORD eventRecord;
        DWORD numRead=0;
        ::ReadConsoleInput(m_Handle,&eventRecord,1,&numRead);
        if(eventRecord.EventType!=KEY_EVENT) return -1;
        if(!eventRecord.Event.KeyEvent.bKeyDown) return -1;
        return eventRecord.Event.KeyEvent.wVirtualKeyCode;
    }

    /*******************************************************************************************************************
    Installs a handler function that will be called periodically that includes the pressed key and the template object
    f: The handler function that has the object of type T argument and the last key that was pressed if any
    sleepTimeBetweenCalls: The amount of time to sleep (in milliseconds) between calls to the handler
    *******************************************************************************************************************/
    void InstallKeyHandler(KEY_HANDLER_FUNC f,DWORD sleepTimeBetweenCalls=20)
    {
        m_KeyHandlerFunc=f;
        m_SleepTimeBetweenCalls=sleepTimeBetweenCalls;
    }

    /*******************************************************************************************************************
    Runs the key handler with the provided device.  This will periodically call the key handler function.  If the
    input key is the escape key it will exit the function.
    *******************************************************************************************************************/
    void RunKeyHandler(const T& device) const
    {
        if(m_KeyHandlerFunc==nullptr) return;
        std::cout << "Press the escape key to exit..." << std::endl;
        while(true)
        {
            auto key=this->LastKeyPressed();
            if(key==VK_ESCAPE) return;
            m_KeyHandlerFunc(device,key);
            ::Sleep(m_SleepTimeBetweenCalls);
        }
    }

    /*******************************************************************************************************************
    Allows you to turn on or off the console cursor
    showFlag: true to show the console cursor, false to turn it off
    *******************************************************************************************************************/
    static void ShowConsoleCursor(bool showFlag)
    {
        HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);
        CONSOLE_CURSOR_INFO  cursorInfo;
        GetConsoleCursorInfo(out,&cursorInfo);
        cursorInfo.bVisible = showFlag; // set the cursor visibility
        SetConsoleCursorInfo(out,&cursorInfo);
    }

private:
    KEY_HANDLER_FUNC m_KeyHandlerFunc;
    HANDLE m_Handle;
    DWORD m_SleepTimeBetweenCalls;

};




#endif;

