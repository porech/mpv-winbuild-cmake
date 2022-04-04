ExternalProject_Add(jack2
    DEPENDS
        tre
        ffmpeg
    GIT_REPOSITORY https://github.com/jackaudio/jack2.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_SHALLOW 1
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC}
        cd <SOURCE_DIR> &&
        PKG_CONFIG=pkg-config
        TARGET=${TARGET_ARCH}
        DEST_OS=win32
        <SOURCE_DIR>/waf configure
        --out=<BINARY_DIR>
        --top=<SOURCE_DIR>
        --prefix=${MINGW_INSTALL_PREFIX}
        --platform=win32
        --static
    BUILD_COMMAND ${EXEC} cd <SOURCE_DIR> && <SOURCE_DIR>/waf
    INSTALL_COMMAND ${EXEC} cd <SOURCE_DIR> && <SOURCE_DIR>/waf install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(jack2)
extra_step(jack2)
cleanup(jack2 install)
