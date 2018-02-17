#ifndef SINGLETON_H
#define SINGLETON_H
#include <assert.h>

template <class T>
class Singleton
{
public:
    static T* Instance()
    {
        if(!m_Instance) m_Instance = new T;
        assert(m_Instance != nullptr);
        return m_Instance;
    }

protected:
    Singleton();
    ~Singleton();

private:
    Singleton(Singleton const&);
    Singleton& operator = (Singleton const&);
    static T* m_Instance;
};

template <class T> T* Singleton<T>::m_Instance = nullptr;

#endif // SINGLETON_H
