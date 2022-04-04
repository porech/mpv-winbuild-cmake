if(${TARGET_CPU} MATCHES "x86_64")
    set(tre_target "x86_64-gcc-win64")
else()
    set(tre_target "x86-gcc-win32")
endif()

ExternalProject_Add(tre
    GIT_REPOSITORY https://github.com/laurikari/tre.git
    SOURCE_DIR ${SOURCE_LOCATION}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} <SOURCE_DIR>/configure
        --host=${TARGET_ARCH}
        --prefix=${MINGW_INSTALL_PREFIX}
        --target=${TARGET_ARCH}
        --enable-static
        --disable-shared
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(tre)
extra_step(tre)
autoreconf(tre)
cleanup(tre install)
