if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC "OFF")
else()
    set(STATIC "ON")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maz-1/verb
    REF 1271d8f7b6abf279c7948fab57eb0136c7322839
    SHA512 df5e0d0dad33f1afa4b46148be1c74a73eb2a7ba7bdab737eb87956334549c0a0d5c7d40a97fa2e56bc859297be8e02b1444014ab771ddf51c6c5b9fa3805460
    HEAD_REF master
)

find_program(HAXE_COMMAND haxe 
             PATHS C:/HaxeToolkit/haxe
                   /usr/bin
                   /usr/local/bin
             REQUIRED)
find_program(NEKO_COMMAND neko 
             PATHS C:/HaxeToolkit/neko
                   /usr/bin
                   /usr/local/bin
             REQUIRED)
get_filename_component(HAXE_CMD_DIR ${HAXE_COMMAND} DIRECTORY)
get_filename_component(NEKO_CMD_DIR ${NEKO_COMMAND} DIRECTORY)

set(HAXE_BUILDFILE_CONTENT "-lib promhx \n\
-main verb.Verb \n\
-dce std \n\
-D static_link \n")

#set(HAXE_BUILDFILE_CONTENT "${HAXE_BUILDFILE_CONTENT}\
#-cpp build/cpp \n")

#set(HAXE_BUILDFILE_CONTENT "${HAXE_BUILDFILE_CONTENT}\
#-cp src \n")

set(HAXE_BUILDFILE_CONTENT "${HAXE_BUILDFILE_CONTENT}\
-cp ${SOURCE_PATH}/src \n")

if (TARGET_TRIPLET MATCHES "^(x64|arm64).*")
    set(HAXE_BUILDFILE_CONTENT "${HAXE_BUILDFILE_CONTENT}\
-D HXCPP_M64 \n")
endif()

if (VCPKG_HOST_IS_WINDOWS)
    set(PATH_SEP ";")
else()
    set(PATH_SEP ":")
endif()

set(LIB_SUFFIX "a")

if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    if (NOT VCPKG_TARGET_IS_MINGW)
        set(LIB_SUFFIX "lib")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(ABI_RELEASE "MT")
        set(ABI_DEBUG "MTd")
    else()
        set(ABI_RELEASE "MD")
        set(ABI_DEBUG "MDd")
    endif()
    set(HAXE_BUILDFILE_CONTENT_RELEASE "${HAXE_BUILDFILE_CONTENT}\
-D ABI=-${ABI_RELEASE} \n\
-cpp ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(HAXE_BUILDFILE_CONTENT_DEBUG "${HAXE_BUILDFILE_CONTENT}\
-D ABI=-${ABI_DEBUG} \n\
-cpp ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
endif()

set(ENV{PATH} "${HAXE_CMD_DIR}${PATH_SEP}${NEKO_CMD_DIR}${PATH_SEP}$ENV{PATH}")
set(ENV{HAXEPATH} "${SOURCE_PATH}/deps")
#set(ENV{NEKO_INSTPATH} "${NEKO_CMD_DIR}")
execute_process(COMMAND haxelib install hxcpp
                WORKING_DIRECTORY "${SOURCE_PATH}")
execute_process(COMMAND haxelib install promhx
                WORKING_DIRECTORY "${SOURCE_PATH}")

foreach(HAXE_PKG hxcpp promhx)
    get_filename_component(PKG_VERSION_FILE $ENV{HAXEPATH}/lib/${HAXE_PKG}/.current ABSOLUTE)
    if(NOT EXISTS "${PKG_VERSION_FILE}")
        message( FATAL_ERROR "Cannot find ${HAXE_PKG}." )
    endif()
    file(READ "${PKG_VERSION_FILE}" PKG_VERSION)
    string(REGEX MATCH "^[0-9.]*" PKG_VERSION ${PKG_VERSION})
    string(REPLACE "." "," PKG_VERSION_COMMA ${PKG_VERSION})
    if (HAXE_PKG STREQUAL "hxcpp")
        set(HXCPP_INCLUDE_DIR $ENV{HAXEPATH}/lib/${HAXE_PKG}/${PKG_VERSION_COMMA}/include)
        if(NOT EXISTS "${HXCPP_INCLUDE_DIR}")
            message( FATAL_ERROR "Cannot find header files for ${HAXE_PKG}." )
        endif()
    endif()
endforeach()
                


file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(WRITE "${SOURCE_PATH}/build_cpp_dbg.hxml" ${HAXE_BUILDFILE_CONTENT_DEBUG})
execute_process(COMMAND haxe build_cpp_dbg.hxml -debug
                WORKING_DIRECTORY "${SOURCE_PATH}")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libVerb-debug.${LIB_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
                
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(WRITE "${SOURCE_PATH}/build_cpp_rel.hxml" ${HAXE_BUILDFILE_CONTENT_RELEASE})
execute_process(COMMAND haxe build_cpp_rel.hxml
                WORKING_DIRECTORY "${SOURCE_PATH}")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libVerb.${LIB_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
#vcpkg_copy_pdbs()

file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/include DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/include ${CURRENT_PACKAGES_DIR}/include/Verb)
file(COPY "${HXCPP_INCLUDE_DIR}" DESTINATION ${CURRENT_PACKAGES_DIR}/include/Verb)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/Verb/include ${CURRENT_PACKAGES_DIR}/include/Verb/hxcpp)
#file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/HxcppConfig-19.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/Verb/hxcpp/)
file(GLOB HXCPP_CONFIG_HEADERS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/HxcppConfig-*.h"
)
#file(COPY ${HXCPP_CONFIG_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Verb/hxcpp/)
file(INSTALL ${HXCPP_CONFIG_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Verb/hxcpp/ RENAME HxcppConfig.h)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/hxcpp_defs.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/Verb/hxcpp/)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/Verb-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

#vcpkg_fixup_pkgconfig()
#file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/citygml.pc" PKGCONFIG_FILE)
#string(REGEX REPLACE "-lcitygml" "-lcitygmld" PKGCONFIG_FILE_MODIFIED "${PKGCONFIG_FILE}" )
#file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/citygml.pc" ${PKGCONFIG_FILE_MODIFIED})




