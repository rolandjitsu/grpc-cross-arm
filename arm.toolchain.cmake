# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-linux
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)

# Architecture / Processor
if(DEFINED ENV{CMAKE_SYSTEM_PROCESSOR})
  set(CMAKE_SYSTEM_PROCESSOR $ENV{CMAKE_SYSTEM_PROCESSOR})
elseif(DEFINED ENV{GNU_HOST} AND "$ENV{GNU_HOST}" MATCHES "^aarch64")
  set(CMAKE_SYSTEM_PROCESSOR aarch64)
else()
  set(CMAKE_SYSTEM_PROCESSOR arm)
endif()

# Sysroot configuration (Debian/Ubuntu cross-compilers have built-in sysroots; only set if an external sysroot exists)
if(DEFINED ENV{CMAKE_SYSROOT})
  set(CMAKE_SYSROOT $ENV{CMAKE_SYSROOT})
elseif(DEFINED ENV{CROSS_TOOLCHAIN} AND EXISTS "$ENV{CROSS_TOOLCHAIN}/sysroot")
  set(CMAKE_SYSROOT $ENV{CROSS_TOOLCHAIN}/sysroot)
endif()

# Staging Prefix
if(DEFINED ENV{CROSS_STAGING_PREFIX})
  set(CMAKE_STAGING_PREFIX $ENV{CROSS_STAGING_PREFIX})
else()
  message(FATAL_ERROR "CROSS_STAGING_PREFIX env var is missing")
endif()

# C Compiler
if(DEFINED ENV{C_COMPILER_ARM_LINUX})
  set(CMAKE_C_COMPILER /usr/bin/$ENV{C_COMPILER_ARM_LINUX})
elseif(DEFINED ENV{GNU_HOST})
  set(CMAKE_C_COMPILER /usr/bin/$ENV{GNU_HOST}-gcc)
else()
  message(FATAL_ERROR "C compiler env var is missing (specify C_COMPILER_ARM_LINUX or GNU_HOST)")
endif()

# C++ Compiler
if(DEFINED ENV{CXX_COMPILER_ARM_LINUX})
  set(CMAKE_CXX_COMPILER /usr/bin/$ENV{CXX_COMPILER_ARM_LINUX})
elseif(DEFINED ENV{GNU_HOST})
  set(CMAKE_CXX_COMPILER /usr/bin/$ENV{GNU_HOST}-g++)
else()
  message(FATAL_ERROR "CXX compiler env var is missing (specify CXX_COMPILER_ARM_LINUX or GNU_HOST)")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
