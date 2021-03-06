if(WIN32)
  set(XERCES_CONFIG "ICU Debug")
  if(CONFIG MATCHES "Rel")
    set(XERCES_CONFIG "ICU Release")
  endif()

  set(XERCES_PLATFORM Win32)
  if(EP_PLATFORM_BITS STREQUAL 64)
    set(XERCES_PLATFORM x64)
  endif()

  set(XERCES_PLATFORM_PATH Win32)
  if(EP_PLATFORM_BITS STREQUAL 64)
    set(XERCES_PLATFORM_PATH Win64)
  endif()

  # VS 10.0
  if(NOT MSVC_VERSION VERSION_LESS 1600 AND MSVC_VERSION VERSION_LESS 1700)
    set(XERCES_SOLUTION VC10)
  # VS 11.0
  elseif(NOT MSVC_VERSION VERSION_LESS 1700 AND MSVC_VERSION VERSION_LESS 1800)
    set(XERCES_SOLUTION VC11)
  # VS 12.0
  elseif(NOT MSVC_VERSION VERSION_LESS 1800 AND MSVC_VERSION VERSION_LESS 1900)
    set(XERCES_SOLUTION VC12)
  # VS 14.0
  elseif(NOT MSVC_VERSION VERSION_LESS 1900 AND MSVC_VERSION VERSION_LESS 2000)
    set(XERCES_SOLUTION VC14)
  else()
    message(FATAL_ERROR "VS version not supported by xerces")
  endif()
endif()