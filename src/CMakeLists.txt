

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
#link_directories (
#    ${CMAKE_BINARY_DIR}
#    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
#)

include_directories (${CMAKE_CURENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})

set (HDFEOS_SRC_CSRCS
    EHapi.c
    GDapi.c
    PTapi.c
    SWapi.c
)

set (HDFEOS_SRC_CHDRS
    HE2_config.h
    HdfEosDef.h
    HDFEOSVersion.h
    cfortHdf.h
    ease.h
)

if (H5_USE_HDFEOS2)
  add_definitions (-DHAVE_LIBHDFEOS)
endif ()

add_library (${HDFEOS_SRC_LIB_TARGET} ${LIB_TYPE} ${HDFEOS_SRC_CSRCS} ${HDFEOS_SRC_CHDRS})
if (MSVC)
  target_link_libraries (${HDFEOS_SRC_LIB_TARGET} "ws2_32.lib")
#else ()
#  set_target_properties (${HDFEOS_SRC_LIB_TARGET} PROPERTIES LINK_FLAGS "-Wl,-single_module")
endif ()
target_link_libraries (${HDFEOS_SRC_LIB_TARGET} ${LINK_LIBS})

if(DEPENDENCY_LIB)
    add_dependencies(${HDFEOS_SRC_LIB_TARGET} ${DEPENDENCY_LIB})  
endif() 

set (HDFEOS_LIBRARIES_TO_EXPORT ${HDFEOS_LIBRARIES_TO_EXPORT} ${HDFEOS_SRC_LIB_TARGET} PARENT_SCOPE)

if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIB_VERSION ${PACKAGE_VERSION_MAJOR})
    else ()
      set (LIB_VERSION ${PACKAGE_VERSION})
    endif ()
    set_target_properties (${HDFEOS_SRC_LIB_TARGET} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${HDFEOS_SRC_LIB_TARGET} PROPERTIES SOVERSION ${LIB_VERSION})
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (HDFEOS_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (HDFEOS_BUILD_WITH_INSTALL_NAME)
      set_target_properties(HDFEOS_SRC_LIB_TARGET PROPERTIES
          LINK_FLAGS "-current_version ${HDFEOS_PACKAGE_VERSION} -compatibility_version ${HDFEOS_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${INSTALL_LIB_DIR}"
          BUILD_WITH_INSTALL_RPATH ${HDFEOS_BUILD_WITH_INSTALL_NAME}
      )
    endif ()
endif ()

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
if (NOT HDFEOS_INSTALL_NO_DEVELOPMENT)
  install (
      FILES
          ${HDFEOS_SRC_CHDRS}
      DESTINATION
          ${INSTALL_INC_DIR}
      COMPONENT
          headers
  )
endif ()

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (HDFEOS_EXPORTED_TARGETS)

  #INSTALL_TARGET_PDB (${HDFEOS_SRC_LIB_TARGET} ${INSTALL_LIB_DIR} libraries)
  
  install (
      TARGETS 
          ${HDFEOS_SRC_LIB_TARGET}
      EXPORT
          ${HDFEOS_EXPORTED_TARGETS}
      LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries 
      ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT libraries
  )
endif ()
