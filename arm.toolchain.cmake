# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-linux
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

if(DEFINED ENV{CROSS_TOOLCHAIN})
  set(CMAKE_SYSROOT $ENV{CROSS_TOOLCHAIN}/sysroot)
else()
  message(FATAL_ERROR "CROSS_TOOLCHAIN env var is missing")
endif()

if(DEFINED ENV{CROSS_STAGING_PREFIX})
  set(CMAKE_STAGING_PREFIX $ENV{CROSS_STAGING_PREFIX})
else()
  message(FATAL_ERROR "CROSS_STAGING_PREFIX env var is missing")
endif()

if(DEFINED ENV{C_COMPILER_ARM_LINUX})
  set(CMAKE_C_COMPILER /usr/bin/$ENV{C_COMPILER_ARM_LINUX})
else()
  message(FATAL_ERROR "C_COMPILER_ARM_LINUX env var is missing")
endif()

if(DEFINED ENV{CXX_COMPILER_ARM_LINUX})
  set(CMAKE_CXX_COMPILER /usr/bin/$ENV{CXX_COMPILER_ARM_LINUX})
else()
  message(FATAL_ERROR "CXX_COMPILER_ARM_LINUX env var is missing")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)