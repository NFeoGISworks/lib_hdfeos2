################################################################################
# Project:  Lib hdfeos2
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

include (CheckSymbolExists)
include (CheckIncludeFiles)
include (CheckLibraryExists) 
include (CheckFunctionExists)
include (TestBigEndian)
include (CheckTypeSize)

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

set(CMAKE_REQUIRED_INCLUDES math.h)
set(CMAKE_REQUIRED_LIBRARIES m)

if (BUILD_SHARED_LIBS)
  set (HDFEOS_BUILT_AS_DYNAMIC_LIB 1)
else ()
  set (HDFEOS_BUILT_AS_STATIC_LIB 1)
endif ()

if (NOT USE_SHARED_LIBS)
  set (HDFEOS_USE_STATIC_LIBRARIES 1)
endif ()

if (WIN32)
  if (MINGW)
    set (WINDOWS 1) # MinGW tries to imitate Windows
    set (CMAKE_REQUIRED_FLAGS "-DWIN32_LEAN_AND_MEAN=1 -DNOGDI=1")
  endif ()
  set (CMAKE_REQUIRED_LIBRARIES "ws2_32.lib;wsock32.lib")
  if (NOT UNIX AND NOT CYGWIN AND NOT MINGW)
    set (WINDOWS 1)
    set (CMAKE_REQUIRED_FLAGS "/DWIN32_LEAN_AND_MEAN=1 /DNOGDI=1")
  endif ()
endif ()

check_include_files ("dlfcn.h"         HAVE_DLFCN_H)
check_include_files ("inttypes.h"      HAVE_INTTYPES_H)
check_include_files ("limits.h"        HAVE_LIMITS_H)
check_function_exists ( malloc         HAVE_MALLOC)
check_include_files ("malloc.h"        HAVE_MALLOC_H)
check_include_files ("unistd.h"        HAVE_UNISTD_H)

check_library_exists (m ceil ""        HAVE_LIBM) 

check_function_exists (memchr          HAVE_MEMCHR)
check_function_exists (memmove         HAVE_MEMMOVE)
check_function_exists (memset          HAVE_MEMSET)
check_function_exists (pow             HAVE_POW)
check_function_exists (realloc         HAVE_REALLOC)
check_function_exists (sqrt            HAVE_SQRT)

check_include_files ("memory.h"        HAVE_MEMORY_H)
check_include_files ("stdint.h"        HAVE_STDINT_H)

check_function_exists(strchr           HAVE_STRCHR)
check_function_exists(strstr           HAVE_STRSTR)

check_function_exists(rpl_malloc       HAVE_RPL_MALLOC)
if(HAVE_RPL_MALLOC)
    set(malloc rpl_malloc)
endif()

check_function_exists(rpl_realloc      HAVE_RPL_REALLOC)
if(HAVE_RPL_REALLOC)
    set(realloc rpl_realloc)
endif()

check_include_files ("string.h"        HAVE_STRING_H)
check_include_files ("strings.h"       HAVE_STRINGS_H)
check_include_files ("sys/stat.h"      HAVE_SYS_STAT_H)
check_include_files ("sys/types.h"     HAVE_SYS_TYPES_H)

check_include_files ("ctype.h"         HAVE_CTYPE_H)
check_include_files ("stdlib.h"        HAVE_STDLIB_H)
if (HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(STDC_HEADERS 1)
endif ()

check_type_size (off_t                 SIZEOF_OFF_T)
if(NOT SIZEOF_OFF_T)
    set(off_t "long int")
endif()

check_type_size (size_t                SIZEOF_SIZE_T)
if(NOT SIZEOF_SIZE_T)
    set(size_t "unsigned int")
endif()

set (PACKAGE "hdf-eos2")
set (PACKAGE_NAME "hdf-eos2")
set (PACKAGE_VERSION "${HDFEOS_VERS_MAJOR}.${HDFEOS_VERS_MINOR}.${HDFEOS_VERS_RELEASE}")
set (PACKAGE_VERSION_MAJOR "${HDFEOS_VERS_MAJOR}.${HDFEOS_VERS_MINOR}")
set (PACKAGE_VERSION_MINOR "${HDFEOS_VERS_RELEASE}")
set (PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set (PACKAGE_TARNAME "hdf-eos2")
set (PACKAGE_URL "http://www.hdfgroup.org")
set (PACKAGE_BUGREPORT "help@hdfgroup.org")

configure_file(${CMAKE_MODULE_PATH}/HE2_config.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/HE2_config.h IMMEDIATE @ONLY)
add_definitions (-DHAVE_CONFIG_H)

