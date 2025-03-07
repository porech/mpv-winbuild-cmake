ExternalProject_Add(opus
    GIT_REPOSITORY https://github.com/xiph/opus.git
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DOPUS_STACK_PROTECTOR=OFF
        -DOPUS_BUILD_PROGRAMS=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_C_FLAGS='${CMAKE_C_FLAGS} -D_FORTIFY_SOURCE=0'
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(opus)
extra_step(opus)
cleanup(opus install)
