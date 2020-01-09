#pragma once
#include <vector>
#include <numeric>

class Averager
{
public:
    Averager(const size_t count):m_items(count,0.0){}

    void Add(double item)
    {
        m_items[position]=item;
        position++;
        position%=m_items.size();
    }

    double Average() const
    {
        const auto sum=std::accumulate(m_items.begin(),m_items.end(),0.0);
        const auto average=sum/m_items.size();
        return average;
    }
private:
    size_t position=0;
    std::vector<double> m_items;
};
