#pragma once
#include <windows.h>
#include <mutex>

template<typename T>class PeriodicTimer
{
public:
    PeriodicTimer(T* obj,void (T::*func)(),DWORD dueTime):m_obj(obj),m_func(func),m_DueTime(dueTime)
    {
        LARGE_INTEGER liDueTime;
        liDueTime.QuadPart=0;
        m_hTimer=::CreateWaitableTimer(nullptr,FALSE,nullptr);
        auto chk=::SetWaitableTimer(m_hTimer,&liDueTime,m_DueTime,nullptr,nullptr,FALSE);
        m_hThread=CreateThread(nullptr,0,ThreadProc,this,0,nullptr);
    }

    void Period(DWORD ms){m_PeriodInMilliSeconds=ms;}

private:
    static DWORD ThreadProc(void* p)
    {
        auto pthis=reinterpret_cast<PeriodicTimer*>(p);
        while(::WaitForSingleObject(pthis->m_hTimer,INFINITE)==WAIT_OBJECT_0)
        {
            ((pthis->m_obj)->*(pthis->m_func))();
        }

        return 0;
    }

    T* m_obj;
    void (T::*m_func)();
    HANDLE m_hTimer;
    const DWORD m_DueTime;
    DWORD m_PeriodInMilliSeconds;
    HANDLE m_hThread;
};
