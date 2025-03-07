ExternalProject_Add(game-music-emu
    GIT_REPOSITORY https://bitbucket.org/mpyne/game-music-emu.git
    GIT_SHALLOW 1
    UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} -DBUILD_SHARED_LIBS=OFF -DENABLE_UBSAN=NO
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(game-music-emu)
extra_step(game-music-emu)
cleanup(game-music-emu install)
