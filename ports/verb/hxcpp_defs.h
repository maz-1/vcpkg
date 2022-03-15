#pragma once
#ifdef WIN32
	#define HX_WINDOWS
	#ifdef _WIN64
		#define HXCPP_M64
	#endif
#endif
#ifdef NDEBUG
	#define NO_HXCPP_DEBUG
#else
#endif
#include <HxcppConfig.h>
#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <iostream>

static inline int HaxeInitGC()
{
	HX_TOP_OF_STACK
    hx::Boot();
    try
    {
         __boot_all();
    }
    catch (Dynamic e)
    {
         __hx_dump_stack();
         #ifdef HX_WIN_MAIN
         MessageBoxA(0,  e==null() ? "null" : e->toString().__CStr(), "Error", 0);
         #else
         printf("Error : %s\n",e==null() ? "null" : e->toString().__CStr());
         #endif
         return -1;
    }
    return 0;
}


template <class T>
void HaxeAssignArray(int idx, Array<T>& arr)
{
}
template <class T, class ...Args>
void HaxeAssignArray(int idx, Array<T>& arr, T head, Args... rest)
{
    arr[idx] = head;
    HaxeAssignArray<T>(idx+1, arr, rest...);
}
template <class T, class ...Args>
Array<T> HaxeCreateArray(T head, Args... rest)
{
    int n = sizeof...(rest)+1;
    Array<T> arr(n, n);
    arr[0] = head;
    HaxeAssignArray<T>(1, arr, rest...);
    return arr;
}

