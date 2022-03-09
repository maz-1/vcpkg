include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iamantony/qtcsv
    REF v1.6
    #SHA512 02b656eea93bbd5e1db665816593d4c0240977c6624defef46270b9aa33df9969f8fea0f7aa7a99d0f71fd1b500f2cd72932156dc054a814422290cd60ccf4f0
    SHA512 4f4b324b27bb58f0ec5fd57be7b240a6c114c170aa97c14cdd807810a684a6491b77d8c93f925626e1eb41ca48c58207f1ad58730dbb3368593dc4e5f1df6dac
    HEAD_REF master
    PATCHES
        #fix_qt5.patch
        fix_cmake_install_path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        #-DBOOST_UUID_FORCE_AUTO_LINK=ON
        #-DXERCES_ROOT=${CURRENT_INSTALLED_DIR}
        -DSTATIC_LIB=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

#file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/qtcsv-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

## Extra steps
# Duplicate this line in qtcsvConfig.cmake: get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)