################################################################################
# Project:  Lib hdfeos
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
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project (hdfeos C CXX)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

include(GNUInstallDirs)

set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
set(INSTALL_DATA_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Installation directory for share files" FORCE)


#-----------------------------------------------------------------------------
# Allow Visual Studio solution directories
#-----------------------------------------------------------------------------
# Provide a way for Visual Studio Express users to turn OFF the new FOLDER
# organization feature. Default to ON for non-Express users. Express users must
# explicitly turn off this option to build HDFEOS in the Express IDE...
#
option (HDFEOS_USE_FOLDERS "Enable folder grouping of projects in IDEs." ON)
mark_as_advanced (HDFEOS_USE_FOLDERS)
if (HDFEOS_USE_FOLDERS)
  set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif (HDFEOS_USE_FOLDERS)
option (HDFEOS_NO_PACKAGES "CPACK - Disable packaging" OFF)
mark_as_advanced (HDFEOS_NO_PACKAGES)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
set (HDFEOS_GCTP_SRC_LIB_CORENAME     "Gctp")
set (HDFEOS_SRC_LIB_CORENAME          "hdfeos")
if(NOT BUILD_SHARED_LIBS)
    set(HDFEOS_EXTERNAL_LIB_POSTFIX static)
endif()

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
set (HDFEOS_GCTP_SRC_LIB_NAME     "${HDFEOS_EXTERNAL_LIB_PREFIX}${HDFEOS_GCTP_SRC_LIB_CORENAME}${HDFEOS_EXTERNAL_LIB_POSTFIX}")
set (HDFEOS_SRC_LIB_NAME          "${HDFEOS_EXTERNAL_LIB_PREFIX}${HDFEOS_SRC_LIB_CORENAME}${HDFEOS_EXTERNAL_LIB_POSTFIX}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
set (HDFEOS_GCTP_SRC_LIB_TARGET     ${HDFEOS_GCTP_SRC_LIB_NAME})
set (HDFEOS_SRC_LIB_TARGET          ${HDFEOS_SRC_LIB_NAME})

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (HDFEOS_GCTP_SRC_DIR        ${CMAKE_SOURCE_DIR}/gctp)
set (HDFEOS_GCTP_INC_DIR        ${CMAKE_SOURCE_DIR}/gctp)
set (HDFEOS_SRC_DIR             ${CMAKE_SOURCE_DIR}/src)
set (HDFEOS_INC_DIR             ${CMAKE_SOURCE_DIR}/src)

#-----------------------------------------------------------------------------
# parse the full version number
#-----------------------------------------------------------------------------
include(util)
set(HDFEOS_FULL_VERSION)
set(HDFEOS_VERS_MAJOR)
set(HDFEOS_VERS_MINOR)
set(HDFEOS_VERS_RELEASE 0)

check_version(HDFEOS_VERS_MAJOR HDFEOS_VERS_MINOR HDFEOS_FULL_VERSION)

set(VERSION "${HDFEOS_VERS_MAJOR}.${HDFEOS_VERS_MINOR}")

report_version(${PROJECT_NAME} "${VERSION}")  

#-----------------------------------------------------------------------------
# configure
#-----------------------------------------------------------------------------
include(FindAnyProject)
find_anyproject(ZLIB REQUIRED)
if(ZLIB_FOUND)
    set (HAVE_FILTER_DEFLATE 1)
    set (HAVE_ZLIB_H 1)
    set (HAVE_LIBZ 1)
    set (ZLIB_HEADER "zlib.h")
    set (HDFEOS_ENABLE_Z_LIB_SUPPORT ON)
endif()

find_anyproject(JPEG REQUIRED)
if(JPEG_FOUND)
    set (HAVE_JPEGLIB_H 1)
    set (HAVE_LIBJPEG 1)
    set (JPEGLIB_HEADER "jpeglib.h")
    set (HDFEOS_ENABLE_JPEG_LIB_SUPPORT ON)
endif()

find_anyproject(SZIP DEFAULT OFF)
if(SZIP_FOUND)
    set (HDFEOS_ENABLE_SZIP_SUPPORT ON)
    option(HDFEOS_ENABLE_SZIP_ENCODING "Use SZip Encoding" OFF)
    if(HDFEOS_ENABLE_SZIP_ENCODING)
        set (HAVE_HDF4_SZIP_ENCODER 1)
        set (HDF4_ENABLE_SZIP_ENCODING 1)        
    endif()
    set (HAVE_HDF4_SZIP_DECODER 1)
    set (HAVE_FILTER_SZIP 1)
    set (HAVE_SZLIB_H 1)
    set (HAVE_LIBSZ 1)
endif()

find_anyproject(HDF4 REQUIRED)
if(HDF4_FOUND)
    set (HAVE_HDF_H 1)
    set (HAVE_HDF4 1)
    set (HDF4_HEADER "hdf.h")
    set (HAVE_LIBDF 1)
    set (HAVE_MFHDF_H 1)
    set (HAVE_LIBMFHDF 1) # todo: add to FindHDF4 variable
endif()

set(LINK_LIBS ${LINK_LIBS} ${TARGET_LINK_LIB})

include(configure)
configure_file(${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)


#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindEOS.
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXPORTED_TARGETS)
  set (HDFEOS_EXPORTED_TARGETS "hdfeos-targets")
endif ()

#-----------------------------------------------------------------------------
# Option to use legacy naming for windows libs/programs, default is legacy
#-----------------------------------------------------------------------------
if (WIN32 AND NOT CYGWIN)
  option (HDFEOS_LEGACY_NAMING "Use Legacy Names for Libraries and Programs" ON)
endif ()

#-----------------------------------------------------------------------------
# Option to Build Shared/Static libs, default is static
#-----------------------------------------------------------------------------
set (LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
  set (LIB_TYPE SHARED)
  add_definitions (-DHDFEOS_BUILT_AS_DYNAMIC_LIB)
  add_definitions (-DH4_BUILT_AS_DYNAMIC_LIB)
else ()
  add_definitions (-DHDFEOS_BUILT_AS_STATIC_LIB)
  add_definitions (-DH4_BUILT_AS_STATIC_LIB)
  if (NOT WIN32)
    # should this be a user setting : Everyone uses it anyway ?
    add_definitions (-DPIC)
  endif ()
endif ()


add_definitions (-DBIG_LONGS -DSWAP)
if (MSVC)
  add_definitions (-DVISUAL_CPLUSPLUS)
endif ()

if (EOS_HAVE_F2CFORTRAN_MACRO)
  add_definitions (-Df2cFortran)
endif ()

#-----------------------------------------------------------------------------
# Option to use code coverage
#-----------------------------------------------------------------------------
option (HDF_ENABLE_COVERAGE "Enable code coverage for Libraries and Programs" OFF)
if (HDF_ENABLE_COVERAGE)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    set (LDFLAGS "${LDFLAGS} -fprofile-arcs -ftest-coverage")   
endif ()

#-----------------------------------------------------------------------------
# Include the main src and config directories
#-----------------------------------------------------------------------------
set (HDFEOS_INCLUDE_DIRECTORIES
    ${HDFEOS_GCTP_INC_DIR} 
    ${HDFEOS_INC_DIR} 
    ${CMAKE_BINARY_DIR}
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)
include_directories (${HDFEOS_INCLUDE_DIRECTORIES} )

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
if (WIN32)
  if (NOT CYGWIN)
    add_definitions (-DBIND_TO_CURRENT_VCLIBS_VERSION=1)
    add_definitions (-D_CRT_SECURE_NO_WARNINGS)
    add_definitions (-D_CONSOLE)
  endif ()
endif ()

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
endif ()

#-----------------------------------------------------------------------------
# Add some definitions for Debug Builds
#-----------------------------------------------------------------------------
if (CMAKE_BUILD_TYPE MATCHES Debug)
  #-- NMake Makefiles will overwhelm the console with warnings if -Wall is used.
  if (NOT WIN32)
    add_definitions (-Wall)
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -finline-functions -fno-common")
  else ()
    set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
  endif ()
endif ()
if (CMAKE_COMPILER_IS_GNUCXX)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -finline-functions -fno-common")
  else ()
    set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -fomit-frame-pointer -finline-functions -fno-common")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to allow the user to disable compiler warnings
#-----------------------------------------------------------------------------
option (HDFEOS_DISABLE_COMPILER_WARNINGS "Disable compiler warnings" ON)
if (HDFEOS_DISABLE_COMPILER_WARNINGS)
  # MSVC uses /w to suppress warnings.  It also complains if another
  # warning level is given, so remove it.
  if (MSVC)
    set (HDFEOS_WARNINGS_BLOCKED 1)
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /w")
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /w")
  endif ()
  if (WIN32 AND NOT CYGWIN)
    add_definitions (-D_CRT_SECURE_NO_WARNINGS)
  endif ()
  # Borland uses -w- to suppress warnings.
  if (BORLAND)
    set (HDFEOS_WARNINGS_BLOCKED 1)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w-")
  endif ()

  # Most compilers use -w to suppress warnings.
  if (NOT HDFEOS_WARNINGS_BLOCKED)
    SET (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
    SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif ()
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif ()

#-----------------------------------------------------------------------------
# Option to Enable MPI Parallel
#-----------------------------------------------------------------------------
option (HDFEOS_ENABLE_PARALLEL "Enable parallel build (requires MPI)" OFF)
if (HDFEOS_ENABLE_PARALLEL)
  include (FindMPI)
  include_directories (${MPI_C_INCLUDE_PATH})
  if (MPI_C_FOUND)
    set (HDFEOS_HAVE_PARALLEL 1)
    # MPI checks, only do these if MPI_C_FOUND is true, otherwise they always fail
    # and once set, they are cached as false and not regenerated
    set (CMAKE_REQUIRED_LIBRARIES "${MPI_C_LIBRARIES}" )
    check_function_exists (MPI_File_get_size HDFEOS_HAVE_MPI_GET_SIZE) 
    # Used by Fortran + MPI
    check_symbol_exists (MPI_Comm_c2f "${MPI_C_INCLUDE_PATH}/mpi.h"  HDFEOS_HAVE_MPI_MULTI_LANG_Comm)
    check_symbol_exists (MPI_Info_c2f "${MPI_C_INCLUDE_PATH}/mpi.h"  HDFEOS_HAVE_MPI_MULTI_LANG_Info)
  endif ()
endif ()

# Parallel IO usage requires MPI to be Linked and Included
if (HDFEOS_HAVE_PARALLEL)
  set (LINK_LIBS ${LINK_LIBS} ${MPI_C_LIBRARIES})
  if (MPI_C_LINK_FLAGS)
    set (CMAKE_EXE_LINKER_FLAGS ${MPI_C_LINK_FLAGS} ${CMAKE_EXE_LINKER_FLAGS})
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Build utility to copy and strip X lines of file
#-----------------------------------------------------------------------------
if (BUILD_TESTING)
  set (XLATE_UTILITY "xlatefile")
  add_executable(${XLATE_UTILITY} ${CMAKE_SOURCE_DIR}/cmake/xlatefile.c)
endif ()

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build HDFEOS Unit Testing" OFF)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200
      CACHE INTEGER
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)
  set (VALGRIND_COMMAND "/usr/bin/valgrind")
  set (VALGRIND_COMMAND_OPTIONS "-v --tool=memcheck --leak-check=full --track-fds=yes --num-callers=50 --show-reachable=yes --track-origins=yes --malloc-fill=0xff --free-fill=0xfe")
  configure_file (${CMAKE_SOURCE_DIR}/cmake/CTestCustom.cmake ${CMAKE_BINARY_DIR}/CTestCustom.ctest @ONLY)
endif ()

#-----------------------------------------------------------------------------
# Add the HDFEOS Library Target to the build
#-----------------------------------------------------------------------------
add_subdirectory (${CMAKE_SOURCE_DIR}/gctp ${CMAKE_BINARY_DIR}/gctp)
set(LINK_LIBS ${LINK_LIBS} ${HDFEOS_GCTP_SRC_LIB_TARGET})
set(DEPENDENCY_LIB ${DEPENDENCY_LIB} ${HDFEOS_GCTP_SRC_LIB_TARGET})
add_subdirectory (${CMAKE_SOURCE_DIR}/src ${CMAKE_BINARY_DIR}/src)

#-----------------------------------------------------------------------------
# Option to build Fortran bindings/tests/samples
#-----------------------------------------------------------------------------
option (HDFEOS_BUILD_FORTRAN "Build FORTRAN support" OFF)
if (HDFEOS_BUILD_FORTRAN AND HDF4_BUILD_FORTRAN)
  include (HDF4UseFortran)
endif ()

#-----------------------------------------------------------------------------
# Add the samples tests to the build
#-----------------------------------------------------------------------------
option (HDFEOS_BUILD_SAMPLES  "Build HDFEOS Testdrivers" OFF)
if (HDFEOS_BUILD_SAMPLES)
  if (BUILD_TESTING)
    if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
      add_subdirectory(${CMAKE_SOURCE_DIR}/samples ${CMAKE_BINARY_DIR}/samples)
    endif ()
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to build HDFEOS Testdrivers
#-----------------------------------------------------------------------------
option (HDFEOS_BUILD_TESTDRIVERS  "Build HDFEOS Testdrivers" OFF)
if (HDFEOS_BUILD_TESTDRIVERS)
  if (BUILD_TESTING)
    if (EXISTS "${CMAKE_SOURCE_DIR}/testdrivers" AND IS_DIRECTORY "${CMAKE_SOURCE_DIR}/testdrivers")
      add_subdirectory (${CMAKE_SOURCE_DIR}/testdrivers ${PROJECT_BINARY_DIR}/testdrivers)
    endif ()
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
  install (
      EXPORT ${HDFEOS_EXPORTED_TARGETS}
      DESTINATION ${INSTALL_DATA_DIR}/cmake/${PACKAGE}
      FILE ${PACKAGE}${PACKAGE_EXT}-targets.cmake
      COMPONENT configinstall
  )
endif ()

#-----------------------------------------------------------------------------
# Export all exported targets to the build tree for use by parent project
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
    if(BUILD_SHARED_LIBS)
        export (
            TARGETS ${HDFEOS_LIBRARIES_TO_EXPORT} ${HDFEOS_LIB_DEPENDENCIES}
            FILE ${PROJECT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES
        )
    else()
        export (
            TARGETS ${HDFEOS_LIBRARIES_TO_EXPORT} ${HDFEOS_LIB_DEPENDENCIES}
            FILE ${PROJECT_NAME}static-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES
        )    
    endif()    
endif ()
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake) 

write_ext_options()

#-----------------------------------------------------------------------------
# Configure the hdfeos-config.cmake file for the build directory
#-----------------------------------------------------------------------------
set (HDFEOS_INCLUDES_BUILD_TIME
    ${HDFEOS_SRC_DIR}
    ${CMAKE_BINARY_DIR}
)
#set (HDFEOS_VERSION_STRING @PACKAGE_VERSION@)
#set (HDFEOS_VERSION_MAJOR  @PACKAGE_VERSION_MAJOR@)
#set (HDFEOS_VERSION_MINOR  @PACKAGE_VERSION_MINOR@)

configure_file (
    ${CMAKE_SOURCE_DIR}/cmake/hdfeos-config.cmake.build.in 
    ${CMAKE_BINARY_DIR}/${PACKAGE}${PACKAGE_EXT}-config.cmake @ONLY
)

#-----------------------------------------------------------------------------
# Configure the FindHDFEOS.cmake file for the install directory
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
  configure_file (
      ${CMAKE_SOURCE_DIR}/cmake/FindEOS.cmake.in 
      ${CMAKE_BINARY_DIR}/CMakeFiles/FindHDFEOS${PACKAGE_EXT}.cmake @ONLY
  )
  install (
      FILES ${CMAKE_BINARY_DIR}/CMakeFiles/FindHDFEOS${PACKAGE_EXT}.cmake
      DESTINATION ${INSTALL_DATA_DIR}/cmake/${PACKAGE}
      COMPONENT configinstall
  )
endif ()

#-----------------------------------------------------------------------------
# Configure the hdfeos-config.cmake file for the install directory
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
  configure_file (
      ${CMAKE_SOURCE_DIR}/cmake/hdfeos-config.cmake.install.in
      ${CMAKE_BINARY_DIR}/CMakeFiles/${PACKAGE}${PACKAGE_EXT}-config.cmake @ONLY
  )
  install (
      FILES ${CMAKE_BINARY_DIR}/CMakeFiles/${PACKAGE}${PACKAGE_EXT}-config.cmake
      DESTINATION ${INSTALL_DATA_DIR}/cmake/${PACKAGE}
      COMPONENT configinstall
  )
endif ()

#-----------------------------------------------------------------------------
# Configure the hdfeos-config-version .cmake file for the install directory
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
  configure_file (
      ${CMAKE_SOURCE_DIR}/cmake/hdfeos-config-version.cmake.in
      ${CMAKE_BINARY_DIR}/CMakeFiles/${PACKAGE}${PACKAGE_EXT}-config-version.cmake @ONLY
  )
  install (
      FILES ${CMAKE_BINARY_DIR}/CMakeFiles/${PACKAGE}${PACKAGE_EXT}-config-version.cmake
      DESTINATION ${INSTALL_DATA_DIR}/cmake/${PACKAGE}
      COMPONENT configinstall
  )
endif ()

#-----------------------------------------------------------------------------
# Add Document File(s) to CMake Install
#-----------------------------------------------------------------------------
if (NOT HDFEOS_EXTERNALLY_CONFIGURED)
  if (EXISTS "${CMAKE_SOURCE_DIR}/doc" AND IS_DIRECTORY "${CMAKE_SOURCE_DIR}/doc")
    set (doc_files
        ${CMAKE_SOURCE_DIR}/doc/README
    )
    install (
        FILES ${doc_files}
        DESTINATION ${INSTALL_DATA_DIR}/doc/${PACKAGE}/release_docs
        COMPONENT hdfeosdocuments
    )
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Set the cpack variables
#-----------------------------------------------------------------------------
set (CPACK_PACKAGE_VENDOR "HDF_Group")
set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "HDFEOS Installation")
set (CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/doc/README")
set (CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set (CPACK_PACKAGE_INSTALL_DIRECTORY "${PACKAGE_NAME}")
set (CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${PACKAGE_NAME}-${PACKAGE_VERSION}-${LIB_TYPE}")
set (CPACK_PACKAGE_VERSION "${PACKAGE_VERSION}")
set (CPACK_PACKAGE_VERSION_MAJOR "${PACKAGE_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR "${PACKAGE_VERSION_MINOR}")
set (CPACK_PACKAGE_VERSION_PATCH "")
set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/doc/README")
set (CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/doc/README")
set (CPACK_PACKAGE_RELOCATABLE TRUE)

if (WIN32)
  set (CPACK_MONOLITHIC_INSTALL ON)
  set (CPACK_NSIS_CONTACT "${PACKAGE_BUGREPORT}")
  set (CPACK_NSIS_MODIFY_PATH ON)
  set (CPACK_NSIS_PACKAGE_NAME "HDFEOS ${PACKAGE_VERSION}")
else ()
  set (CPACK_PACKAGING_INSTALL_PREFIX "/usr")
  set (CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE ON)

  set (CPACK_DEBIAN_PACKAGE_SECTION "Libraries")
  set (CPACK_DEBIAN_PACKAGE_MAINTAINER "${PACKAGE_BUGREPORT}")
    
  set (CPACK_RPM_COMPONENT_INSTALL ON)
  set (CPACK_RPM_PACKAGE_GROUP "Development/Tools")
  set (CPACK_RPM_PACKAGE_LICENSE "BSD-style")
  set (CPACK_RPM_PACKAGE_URL "${PACKAGE_URL}")
  set (CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "/sbin/ldconfig")
  set (CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "/sbin/ldconfig")
  set (CPACK_RPM_POST_INSTALL_SCRIPT_FILE "/sbin/ldconfig")
  set (CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "/sbin/ldconfig")
  set (CPACK_STRIP_FILES "${HDFEOS_LIBRARIES_TO_EXPORT};${HDFEOS_APPS_TO_EXPORT};${EXTERNAL_LIBRARY_LIST}")
endif ()

include(InstallRequiredSystemLibraries)

set (CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};HDFEOS;ALL;/")

if (PACKAGE_EXTLIBS)
    if (HDFEOS_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDFEOS_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
      if (HDF4_FOUND AND HDF4_USE_EXTERNAL)
        set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${HDF4_INCLUDE_DIR_GEN};HDF4;libraries;/")
        set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${HDF4_INCLUDE_DIR_GEN};HDF4;headers;/")
        set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${HDF4_INCLUDE_DIR_GEN};HDF4;configinstall;/")
        if (JPEG_USE_EXTERNAL)
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${JPEG_INCLUDE_DIR_GEN};jpeg;libraries;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${JPEG_INCLUDE_DIR_GEN};jpeg;headers;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${JPEG_INCLUDE_DIR_GEN};jpeg;configinstall;/")
        endif ()
        if (ZLIB_USE_EXTERNAL)
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${ZLIB_INCLUDE_DIR_GEN};zlib;libraries;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${ZLIB_INCLUDE_DIR_GEN};zlib;headers;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${ZLIB_INCLUDE_DIR_GEN};zlib;configinstall;/")
        endif ()
        if (SZIP_USE_EXTERNAL)
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${SZIP_INCLUDE_DIR_GEN};szip;libraries;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${SZIP_INCLUDE_DIR_GEN};szip;headers;/")
          set (CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${SZIP_INCLUDE_DIR_GEN};szip;configinstall;/")
        endif ()
      endif ()
    endif ()
endif ()

include (CPack)

#-----------------------------------------------------------------------------
# Now list the cpack commands
#-----------------------------------------------------------------------------
cpack_add_component (applications 
    DISPLAY_NAME "HDFEOS Applications" 
    DEPENDS libraries
    GROUP Applications
)
cpack_add_component (libraries 
    DISPLAY_NAME "HDFEOS Libraries"
    GROUP Runtime
)
cpack_add_component (headers 
    DISPLAY_NAME "HDFEOS Headers" 
    DEPENDS libraries
    GROUP Development
)
cpack_add_component (hdfeosdocuments 
    DISPLAY_NAME "HDFEOS Documents"
    GROUP Documents
)
cpack_add_component (configinstall 
    DISPLAY_NAME "HDFEOS CMake files" 
    DEPENDS libraries
    GROUP Development
)

if (HDFEOS_BUILD_TESTDRIVERS)
  cpack_add_component (toolsapplications 
      DISPLAY_NAME "HDFEOS TESTDRIVERS Applications" 
      DEPENDS toolslibraries
      GROUP Applications
  )
  cpack_add_component (toolslibraries 
      DISPLAY_NAME "HDFEOS TESTDRIVERS Libraries" 
      DEPENDS libraries
      GROUP Runtime
  )
  cpack_add_component (toolsheaders 
      DISPLAY_NAME "HDFEOS TESTDRIVERS Headers" 
      DEPENDS toolslibraries
      GROUP Development
  )
endif ()
