get_filename_component(Ogre_glTF_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

IF (NOT "${Ogre_glTF_DIR}/include" EQUAL "${Ogre_glTF_INCLUDE_DIR}")
    SET(Ogre_glTF_LIBRARY_DEBUG Ogre_glTF_LIBRARY_DEBUG-NOTFOUND)
    SET(Ogre_glTF_LIBRARY_RELEASE Ogre_glTF_LIBRARY_RELEASE-NOTFOUND)
    SET(Ogre_glTF_LIBRARY Ogre_glTF_LIBRARY-NOTFOUND)
    SET(Ogre_glTF_LIBRARIES Ogre_glTF_LIBRARIES-NOTFOUND)
    SET(Ogre_glTF_INCLUDE_DIR Ogre_glTF_INCLUDE_DIR-NOTFOUND)
    SET(Ogre_glTF_INCLUDE_DIRS Ogre_glTF_INCLUDE_DIRS-NOTFOUND)
    SET(Ogre_glTF_LIBRARY_DIRS Ogre_glTF_LIBRARY_DIRS-NOTFOUND)
ENDIF()

SET(Ogre_glTF_FOUND TRUE)

FIND_PATH(Ogre_glTF_INCLUDE_DIR
    NAMES Ogre_glTF.hpp
    PATHS ${Ogre_glTF_DIR}/include
    DOC "Ogre_glTF include directory"
)

FIND_LIBRARY(Ogre_glTF_LIBRARY_RELEASE
    NAMES   libOgre_glTF
            Ogre_glTF
    HINTS  ${Ogre_glTF_DIR}/lib
    DOC "Ogre_glTF release library"
)

FIND_LIBRARY(Ogre_glTF_LIBRARY_DEBUG
    NAMES   libOgre_glTF_d
            Ogre_glTF_d
    HINTS  ${Ogre_glTF_DIR}/lib
           ${Ogre_glTF_DIR}/debug/lib
    DOC "Ogre_glTF debug library"
)

MARK_AS_ADVANCED(
    Ogre_glTF_INCLUDE_DIR
    Ogre_glTF_LIBRARY_RELEASE
    Ogre_glTF_LIBRARY_DEBUG
    Ogre_glTF_LIBRARY
)

IF (Ogre_glTF_LIBRARY_DEBUG AND Ogre_glTF_LIBRARY_RELEASE)
  # if the generator supports configuration types then set
  # optimized and debug libraries, or if the CMAKE_BUILD_TYPE has a value
  IF (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
    SET(Ogre_glTF_LIBRARY optimized ${Ogre_glTF_LIBRARY_RELEASE} debug ${Ogre_glTF_LIBRARY_DEBUG})
  ELSE()
    # if there are no configuration types and CMAKE_BUILD_TYPE has no value
    # then just use the release libraries
    SET(Ogre_glTF_LIBRARY ${Ogre_glTF_LIBRARY_RELEASE} )
  ENDIF()
  # FIXME: This probably should be set for both cases
  SET(Ogre_glTF_LIBRARIES optimized ${Ogre_glTF_LIBRARY_RELEASE} debug ${Ogre_glTF_LIBRARY_DEBUG})
ENDIF()

# if only the release version was found, set the debug variable also to the release version
IF (Ogre_glTF_LIBRARY_RELEASE AND NOT Ogre_glTF_LIBRARY_DEBUG)
  SET(Ogre_glTF_LIBRARY_DEBUG ${Ogre_glTF_LIBRARY_RELEASE})
  SET(Ogre_glTF_LIBRARY       ${Ogre_glTF_LIBRARY_RELEASE})
  SET(Ogre_glTF_LIBRARIES     ${Ogre_glTF_LIBRARY_RELEASE})
ENDIF()

# if only the debug version was found, set the release variable also to the debug version
IF (Ogre_glTF_LIBRARY_DEBUG AND NOT Ogre_glTF_LIBRARY_RELEASE)
  SET(Ogre_glTF_LIBRARY_RELEASE ${Ogre_glTF_LIBRARY_DEBUG})
  SET(Ogre_glTF_LIBRARY         ${Ogre_glTF_LIBRARY_DEBUG})
  SET(Ogre_glTF_LIBRARIES       ${Ogre_glTF_LIBRARY_DEBUG})
ENDIF()

IF (Ogre_glTF_LIBRARY)
    set(Ogre_glTF_LIBRARY ${Ogre_glTF_LIBRARY} CACHE FILEPATH "The Ogre_glTF library")
    # Remove superfluous "debug" / "optimized" keywords from
    # RiVLib_LIBRARY_DIRS
    FOREACH(_Ogre_glTF_my_lib ${Ogre_glTF_LIBRARY})
        GET_FILENAME_COMPONENT(_Ogre_glTF_my_lib_path "${_Ogre_glTF_my_lib}" PATH)
        LIST(APPEND Ogre_glTF_LIBRARY_DIRS ${_Ogre_glTF_my_lib_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES Ogre_glTF_LIBRARY_DIRS)

    SET(Ogre_glTF_LIBRARY_DIRS ${Ogre_glTF_LIBRARY_DIRS} FILEPATH "Ogre_glTF library directory")
    SET(Ogre_glTF_FOUND ON CACHE INTERNAL "Whether the Ogre_glTF component was found")
    SET(Ogre_glTF_LIBRARIES ${Ogre_glTF_LIBRARIES} ${Ogre_glTF_LIBRARY})
ELSE(Ogre_glTF_LIBRARY)
    SET(Ogre_glTF_FOUND FALSE) #FIXME: doesn't get propagated to caller
ENDIF(Ogre_glTF_LIBRARY)

IF (Ogre_glTF_FOUND)
    SET(Ogre_glTF_INCLUDE_DIRS ${Ogre_glTF_INCLUDE_DIR} "Ogre_glTF include directory")
ENDIF()


