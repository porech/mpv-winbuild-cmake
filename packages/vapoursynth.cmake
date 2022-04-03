set(rev "R57")

if(${TARGET_CPU} MATCHES "x86_64")
    set(link "https://github.com/vapoursynth/vapoursynth/releases/download/${rev}/VapourSynth64-Portable-${rev}.7z")
    set(hash "04A42F2EE604EB7370DF98C9C9A85D4F7854E96250AB0356BE85D81489710D20")
else()
    set(link "https://github.com/vapoursynth/vapoursynth/releases/download/${rev}/VapourSynth32-Portable-${rev}.7z")
    set(hash "F686A5517D648F99EFAC44F225E2C7922CBFB7E0593AC8A557B5A012D6F57E9A")
    set(dlltool_opts "-U")
endif()

string(REPLACE "R" "" PC_VERSION ${rev})
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth.pc.in ${CMAKE_CURRENT_BINARY_DIR}/vapoursynth.pc @ONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/vapoursynth-script.pc.in ${CMAKE_CURRENT_BINARY_DIR}/vapoursynth-script.pc @ONLY)
set(GENERATE_DEF ${CMAKE_CURRENT_BINARY_DIR}/vapoursynth-prefix/src/generate_def.sh)
file(WRITE ${GENERATE_DEF}
"#!/bin/bash
gendef - $1.dll | sed -r -e 's|^_||' -e 's|@[1-9]+$||' > $1.def")

ExternalProject_Add(vapoursynth
    URL ${link}
    URL_HASH SHA256=${hash}
    DOWNLOAD_DIR ${SOURCE_LOCATION}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1
)

ExternalProject_Add_Step(vapoursynth generate-def
    DEPENDEES install
    WORKING_DIRECTORY <SOURCE_DIR>
    COMMAND chmod 755 ${GENERATE_DEF}
    COMMAND ${EXEC} ${GENERATE_DEF} VSScript
    COMMAND ${EXEC} ${GENERATE_DEF} VapourSynth
    LOG 1
)

ExternalProject_Add_Step(vapoursynth generate-lib
    DEPENDEES generate-def
    WORKING_DIRECTORY <SOURCE_DIR>
    COMMAND ${EXEC} ${TARGET_ARCH}-dlltool -d VSScript.def -y libvsscript.a ${dlltool_opts}
    COMMAND ${EXEC} ${TARGET_ARCH}-dlltool -d VapourSynth.def -y libvapoursynth.a ${dlltool_opts}
    LOG 1
)

ExternalProject_Add_Step(vapoursynth download-header
    DEPENDEES generate-lib
    WORKING_DIRECTORY <SOURCE_DIR>
    COMMAND curl -sOL https://raw.githubusercontent.com/vapoursynth/vapoursynth/${rev}/include/VapourSynth.h
    COMMAND curl -sOL https://raw.githubusercontent.com/vapoursynth/vapoursynth/${rev}/include/VSScript.h
    COMMAND curl -sOL https://raw.githubusercontent.com/vapoursynth/vapoursynth/${rev}/include/VSHelper.h
    LOG 1
)

ExternalProject_Add_Step(vapoursynth manual-install
    DEPENDEES download-header
    WORKING_DIRECTORY <SOURCE_DIR>
    # Copying header
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/VapourSynth.h ${MINGW_INSTALL_PREFIX}/include/vapoursynth/VapourSynth.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/VSScript.h ${MINGW_INSTALL_PREFIX}/include/vapoursynth/VSScript.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/VSHelper.h ${MINGW_INSTALL_PREFIX}/include/vapoursynth/VSHelper.h
    # Copying libs
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libvsscript.a ${MINGW_INSTALL_PREFIX}/lib/libvsscript.a
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libvapoursynth.a ${MINGW_INSTALL_PREFIX}/lib/libvapoursynth.a
    # Copying .pc files
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/vapoursynth.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/vapoursynth.pc
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/vapoursynth-script.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/vapoursynth-script.pc
)

extra_step(vapoursynth)
cleanup(vapoursynth manual-install)
