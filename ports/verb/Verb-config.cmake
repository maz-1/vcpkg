get_filename_component(Verb_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

IF (NOT "${Verb_DIR}/include" EQUAL "${Verb_INCLUDE_DIR}")
    SET(Verb_LIBRARY_DEBUG Verb_LIBRARY_DEBUG-NOTFOUND)
    SET(Verb_LIBRARY_RELEASE Verb_LIBRARY_RELEASE-NOTFOUND)
    SET(Verb_LIBRARY Verb_LIBRARY-NOTFOUND)
    SET(Verb_LIBRARIES Verb_LIBRARIES-NOTFOUND)
    SET(Verb_INCLUDE_DIR Verb_INCLUDE_DIR-NOTFOUND)
    SET(Verb_INCLUDE_DIRS Verb_INCLUDE_DIRS-NOTFOUND)
    SET(Verb_LIBRARY_DIRS Verb_LIBRARY_DIRS-NOTFOUND)
ENDIF()

SET(Verb_FOUND TRUE)

FIND_PATH(Verb_INCLUDE_DIR
    NAMES Std.h
    PATHS ${Verb_DIR}/include/Verb/
    DOC "Verb include directory"
)
          
FIND_LIBRARY(Verb_LIBRARY_RELEASE
    NAMES   libVerb
            Verb
    HINTS  ${Verb_DIR}/lib
    DOC "Verb release library"
)

FIND_LIBRARY(Verb_LIBRARY_DEBUG
    NAMES   libVerb-debug
            Verb-debug
    HINTS  ${Verb_DIR}/lib
           ${Verb_DIR}/debug/lib
    DOC "Verb debug library"
)

MARK_AS_ADVANCED(
    Verb_INCLUDE_DIR
    Verb_LIBRARY_RELEASE
    Verb_LIBRARY_DEBUG
    Verb_LIBRARY
)

IF (Verb_LIBRARY_DEBUG AND Verb_LIBRARY_RELEASE)
  # if the generator supports configuration types then set
  # optimized and debug libraries, or if the CMAKE_BUILD_TYPE has a value
  IF (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
    SET(Verb_LIBRARY optimized ${Verb_LIBRARY_RELEASE} debug ${Verb_LIBRARY_DEBUG})
  ELSE()
    # if there are no configuration types and CMAKE_BUILD_TYPE has no value
    # then just use the release libraries
    SET(Verb_LIBRARY ${Verb_LIBRARY_RELEASE} )
  ENDIF()
  # FIXME: This probably should be set for both cases
  SET(Verb_LIBRARIES optimized ${Verb_LIBRARY_RELEASE} debug ${Verb_LIBRARY_DEBUG})
ENDIF()

# if only the release version was found, set the debug variable also to the release version
IF (Verb_LIBRARY_RELEASE AND NOT Verb_LIBRARY_DEBUG)
  SET(Verb_LIBRARY_DEBUG ${Verb_LIBRARY_RELEASE})
  SET(Verb_LIBRARY       ${Verb_LIBRARY_RELEASE})
  SET(Verb_LIBRARIES     ${Verb_LIBRARY_RELEASE})
ENDIF()

# if only the debug version was found, set the release variable also to the debug version
IF (Verb_LIBRARY_DEBUG AND NOT Verb_LIBRARY_RELEASE)
  SET(Verb_LIBRARY_RELEASE ${Verb_LIBRARY_DEBUG})
  SET(Verb_LIBRARY         ${Verb_LIBRARY_DEBUG})
  SET(Verb_LIBRARIES       ${Verb_LIBRARY_DEBUG})
ENDIF()

IF (Verb_LIBRARY)
    set(Verb_LIBRARY ${Verb_LIBRARY} CACHE FILEPATH "The Verb library")
    # Remove superfluous "debug" / "optimized" keywords from
    # RiVLib_LIBRARY_DIRS
    FOREACH(_Verb_my_lib ${Verb_LIBRARY})
        GET_FILENAME_COMPONENT(_Verb_my_lib_path "${_Verb_my_lib}" PATH)
        LIST(APPEND Verb_LIBRARY_DIRS ${_Verb_my_lib_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES Verb_LIBRARY_DIRS)

    SET(Verb_LIBRARY_DIRS ${Verb_LIBRARY_DIRS} CACHE FILEPATH "Verb library directory")
    SET(Verb_FOUND ON CACHE INTERNAL "Whether the Verb component was found")
    SET(Verb_LIBRARIES ${Verb_LIBRARIES} ${Verb_LIBRARY})
ELSE(Verb_LIBRARY)
    SET(Verb_FOUND FALSE) #FIXME: doesn't get propagated to caller
ENDIF(Verb_LIBRARY)

IF (Verb_FOUND)
    SET(Verb_INCLUDE_DIRS ${Verb_INCLUDE_DIR} ${Verb_INCLUDE_DIR}/hxcpp)
ENDIF()


