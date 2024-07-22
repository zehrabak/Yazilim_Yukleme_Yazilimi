cmake_minimum_required(VERSION 3.16)

# vcpkg paths
set(VCPKG_ROOT "C:/Users/pc/vcpkg")  # vcpkg'nin doğru yolu ile değiştirin
set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")

# Include the vcpkg toolchain
include(${CMAKE_TOOLCHAIN_FILE})

project(YazilimYuklemeProjesi VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick QuickControls2 QuickLayouts QuickDialogs2 LinguistTools)
find_package(libssh CONFIG REQUIRED)

qt_standard_project_setup()

qt_add_executable(appYazilimYuklemeProjesi
    main.cpp
    pinghelper.h
    pinghelper.cpp
    sshhelper.h
    sshhelper.cpp
)

qt_add_qml_module(appYazilimYuklemeProjesi
    URI YazilimYuklemeProjesi
    VERSION 1.0
    QML_FILES
        Main.qml
)

qt_add_lupdate(appYazilimYuklemeProjesi
    TS_FILES
    translations/yazilim_yukleme_tr.ts
    translations/yazilim_yukleme_en.ts
    # SOURCES
    # main.cpp
    # pinghelper.cpp
    # sshhelper.cpp
    # Main.qml
)

qt_add_lrelease(appYazilimYuklemeProjesi
    TS_FILES
    translations/yazilim_yukleme_tr.ts
    translations/yazilim_yukleme_en.ts
    QM_FILES_OUTPUT_VARIABLE qm_files
)

# .qm dosyalarını hedefe eklemek
target_sources(appYazilimYuklemeProjesi PRIVATE ${qm_files})

add_custom_target(show_qm_files ALL
    COMMAND ${CMAKE_COMMAND} -E echo "Updated .qm files: ${updated_qm_files}"
    COMMAND ${CMAKE_COMMAND} -E echo "Generated .qm files: ${qm_files}"
    DEPENDS appYazilimYuklemeProjesi
)
# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appYazilimYuklemeProjesi PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appYazilimYuklemeProjesi
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appYazilimYuklemeProjesi
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts ssh
)

install(DIRECTORY translations DESTINATION ${CMAKE_INSTALL_BINDIR}/translations)

include(GNUInstallDirs)
install(TARGETS appYazilimYuklemeProjesi
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
