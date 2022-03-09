get_filename_component(qtcsv_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

IF (NOT "${qtcsv_DIR}/include" EQUAL "${qtcsv_INCLUDE_DIR}")
    SET(qtcsv_LIBRARY_DEBUG qtcsv_LIBRARY_DEBUG-NOTFOUND)
    SET(qtcsv_LIBRARY_RELEASE qtcsv_LIBRARY_RELEASE-NOTFOUND)
    SET(qtcsv_LIBRARY qtcsv_LIBRARY-NOTFOUND)
    SET(qtcsv_LIBRARIES qtcsv_LIBRARIES-NOTFOUND)
    SET(qtcsv_INCLUDE_DIR qtcsv_INCLUDE_DIR-NOTFOUND)
    SET(qtcsv_INCLUDE_DIRS qtcsv_INCLUDE_DIRS-NOTFOUND)
    SET(qtcsv_LIBRARY_DIRS qtcsv_LIBRARY_DIRS-NOTFOUND)
ENDIF()

SET(qtcsv_FOUND TRUE)

FIND_PATH(qtcsv_INCLUDE_DIR
    NAMES qtcsv_global.h
    PATHS ${qtcsv_DIR}/include/qtcsv
    DOC "qtcsv include directory"
)
          
FIND_LIBRARY(qtcsv_LIBRARY_RELEASE
    NAMES   libqtcsv
            qtcsv
    HINTS  ${qtcsv_DIR}/lib
    DOC "qtcsv release library"
)

FIND_LIBRARY(qtcsv_LIBRARY_DEBUG
    NAMES   libqtcsv
            qtcsv
    HINTS  ${qtcsv_DIR}/debug/lib
           #${qtcsv_DIR}/lib
    DOC "qtcsv debug library"
)

MARK_AS_ADVANCED(
    qtcsv_INCLUDE_DIR
    qtcsv_LIBRARY_RELEASE
    qtcsv_LIBRARY_DEBUG
    qtcsv_LIBRARY
)

IF (qtcsv_LIBRARY_DEBUG AND qtcsv_LIBRARY_RELEASE)
  # if the generator supports configuration types then set
  # optimized and debug libraries, or if the CMAKE_BUILD_TYPE has a value
  IF (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
    SET(qtcsv_LIBRARY optimized ${qtcsv_LIBRARY_RELEASE} debug ${qtcsv_LIBRARY_DEBUG})
  ELSE()
    # if there are no configuration types and CMAKE_BUILD_TYPE has no value
    # then just use the release libraries
    SET(qtcsv_LIBRARY ${qtcsv_LIBRARY_RELEASE} )
  ENDIF()
  # FIXME: This probably should be set for both cases
  SET(qtcsv_LIBRARIES optimized ${qtcsv_LIBRARY_RELEASE} debug ${qtcsv_LIBRARY_DEBUG})
ENDIF()

# if only the release version was found, set the debug variable also to the release version
IF (qtcsv_LIBRARY_RELEASE AND NOT qtcsv_LIBRARY_DEBUG)
  SET(qtcsv_LIBRARY_DEBUG ${qtcsv_LIBRARY_RELEASE})
  SET(qtcsv_LIBRARY       ${qtcsv_LIBRARY_RELEASE})
  SET(qtcsv_LIBRARIES     ${qtcsv_LIBRARY_RELEASE})
ENDIF()

# if only the debug version was found, set the release variable also to the debug version
IF (qtcsv_LIBRARY_DEBUG AND NOT qtcsv_LIBRARY_RELEASE)
  SET(qtcsv_LIBRARY_RELEASE ${qtcsv_LIBRARY_DEBUG})
  SET(qtcsv_LIBRARY         ${qtcsv_LIBRARY_DEBUG})
  SET(qtcsv_LIBRARIES       ${qtcsv_LIBRARY_DEBUG})
ENDIF()

IF (qtcsv_LIBRARY)
    set(qtcsv_LIBRARY ${qtcsv_LIBRARY} CACHE FILEPATH "The qtcsv library")
    # Remove superfluous "debug" / "optimized" keywords from
    # RiVLib_LIBRARY_DIRS
    FOREACH(_qtcsv_my_lib ${qtcsv_LIBRARY})
        GET_FILENAME_COMPONENT(_qtcsv_my_lib_path "${_qtcsv_my_lib}" PATH)
        LIST(APPEND qtcsv_LIBRARY_DIRS ${_qtcsv_my_lib_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES qtcsv_LIBRARY_DIRS)

    SET(qtcsv_LIBRARY_DIRS ${qtcsv_LIBRARY_DIRS} CACHE FILEPATH "qtcsv library directory")
    SET(qtcsv_FOUND ON CACHE INTERNAL "Whether the qtcsv component was found")
    SET(qtcsv_LIBRARIES ${qtcsv_LIBRARIES} ${qtcsv_LIBRARY})
ELSE(qtcsv_LIBRARY)
    SET(qtcsv_FOUND FALSE) #FIXME: doesn't get propagated to caller
ENDIF(qtcsv_LIBRARY)

IF (qtcsv_FOUND)
    SET(qtcsv_INCLUDE_DIRS ${qtcsv_INCLUDE_DIR} CACHE FILEPATH "qtcsv include directory")
ENDIF()


