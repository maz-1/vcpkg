if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC "OFF")
else()
    set(STATIC "ON")
endif()

#include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/maz-1/Ogre_glTF.git")
set(GIT_REV "71dd9e67ecdd6704634e08ba14d35f5335c4d8b4")

if(NOT EXISTS "${DOWNLOADS}/Ogre_glTF.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/Ogre_glTF.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REV}
        WORKING_DIRECTORY ${DOWNLOADS}/Ogre_glTF.git
        LOGNAME worktree
    )
    message(STATUS "Updating sumbodules")
    vcpkg_execute_required_process(
        COMMAND ${GIT} submodule update --init --remote
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME submodule
    )
endif()
message(STATUS "Adding worktree and updating sumbodules done")

vcpkg_cmake_configure(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS -DOgre_glTF_STATIC=${STATIC} -DCMAKE_INSTALL_PREFIX="${CURRENT_PACKAGES_DIR}"
)


vcpkg_cmake_install()
#vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/Ogre_glTF.lib ${CURRENT_PACKAGES_DIR}/lib/Ogre_glTF.lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/Ogre_glTF_d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/Ogre_glTF_d.lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre-gltf RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/Ogre_glTF)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/Ogre_glTF-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/Ogre_glTF")