

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
#link_directories (
#    ${CMAKE_BINARY_DIR}
#    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
#)

include_directories (${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_BINARY_DIR})

set (GCTP_SRC_CSRCS
    gctp.c
    alberfor.c
    alberinv.c
    alconfor.c
    alconinv.c
    azimfor.c
    aziminv.c
    bceafor.c
    bceainv.c
    br_gctp.c
    ceafor.c
    ceainv.c
    cproj.c
    eqconfor.c
    eqconinv.c
    equifor.c
    equiinv.c
    for_init.c
    gnomfor.c
    gnominv.c
    goodfor.c
    goodinv.c
    gvnspfor.c
    gvnspinv.c
    hamfor.c
    haminv.c
    imolwfor.c
    imolwinv.c
    inv_init.c
    isinusfor.c
    isinusinv.c
    lamazfor.c
    lamazinv.c
    lamccfor.c
    lamccinv.c
    merfor.c
    merinv.c
    millfor.c
    millinv.c
    molwfor.c
    molwinv.c
    obleqfor.c
    obleqinv.c
    omerfor.c
    omerinv.c
    orthfor.c
    orthinv.c
    paksz.c
    polyfor.c
    polyinv.c
    psfor.c
    psinv.c
    report.c
    robfor.c
    robinv.c
    sinfor.c
    sininv.c
    sphdz.c
    somfor.c
    sominv.c
    sterfor.c
    sterinv.c
    stplnfor.c
    stplninv.c
    tmfor.c
    tminv.c
    untfz.c
    utmfor.c
    utminv.c
    vandgfor.c
    vandginv.c
    wivfor.c
    wivinv.c
    wviifor.c
    wviiinv.c
)

set (GCTP_HEADERS
    bcea.h
    cproj.h
    cproj_prototypes.h
    gctp_prototypes.h
    proj.h
    isin.h
    gctp_init.h
)

add_library (${HDFEOS_GCTP_SRC_LIB_TARGET} ${LIB_TYPE} ${GCTP_SRC_CSRCS} ${GCTP_HEADERS})
if (MSVC)
  target_link_libraries (${HDFEOS_GCTP_SRC_LIB_TARGET} "ws2_32.lib")
endif ()

if(LINK_LIBS)
    target_link_libraries (${HDFEOS_GCTP_SRC_LIB_TARGET} PRIVATE ${LINK_LIBS})
endif() 
if(DEPENDENCY_LIB)
    add_dependencies(${HDFEOS_GCTP_SRC_LIB_TARGET} ${DEPENDENCY_LIB})  
endif() 

set (HDFEOS_LIBRARIES_TO_EXPORT ${HDFEOS_LIBRARIES_TO_EXPORT} ${HDFEOS_GCTP_SRC_LIB_TARGET} PARENT_SCOPE)

if (BUILD_SHARED_LIBS)
    if (WIN32)
      set (LIB_VERSION ${PACKAGE_VERSION_MAJOR})
    else ()
      set (LIB_VERSION ${PACKAGE_VERSION})
    endif ()
    set_target_properties (${HDFEOS_GCTP_SRC_LIB_TARGET} PROPERTIES VERSION ${LIB_VERSION})
    set_target_properties (${HDFEOS_GCTP_SRC_LIB_TARGET} PROPERTIES SOVERSION ${LIB_VERSION})
    set_target_properties (${HDFEOS_GCTP_SRC_LIB_TARGET} PROPERTIES DEFINE_SYMBOL GCTP_DLL_EXPORTS)
endif ()

#-- Apple Specific install_name for libraries
if (APPLE)
    option (HDFEOS_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (HDFEOS_BUILD_WITH_INSTALL_NAME)
      set_target_properties(HDFEOS_GCTP_SRC_LIB_TARGET PROPERTIES
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
          ${GCTP_HEADERS}
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

  #INSTALL_TARGET_PDB (${HDFEOS_GCTP_SRC_LIB_TARGET} ${HDFEOS_INSTALL_LIB_DIR} libraries)
  
  install (
      TARGETS 
          ${HDFEOS_GCTP_SRC_LIB_TARGET}
      EXPORT
          ${HDFEOS_EXPORTED_TARGETS}
      LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries 
      ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
      RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT libraries
  )
endif ()
