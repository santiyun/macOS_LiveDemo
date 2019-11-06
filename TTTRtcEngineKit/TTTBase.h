#ifndef _TTT_BASE_H_
#define _TTT_BASE_H_
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>

#if defined(_WIN32)
#include <windows.h>
#define TTT_CALL __cdecl
#if defined(TTTRTC_EXPORT)
#define TTT_API __declspec(dllexport)
#define TTT_CAPI extern "C" __declspec(dllexport)
#else
#define TTT_API __declspec(dllimport)
#define TTT_CAPI extern "C" __declspec(dllimport)
#endif
#elif defined(__APPLE__)
#define TTT_API __attribute__((visibility("default")))
#define TTT_CAPI __attribute__((visibility("default"))) extern "C"
#define TTT_CALL
#elif defined(__ANDROID__) || defined(__linux__)
#define TTT_API __attribute__((visibility("default")))
#define TTT_API extern "C" __attribute__((visibility("default")))
#define TTT_CALL
#else
#define TTT_API
#define TTT_CAPI extern "C"
#define TTT_CALL
#endif

#endif
