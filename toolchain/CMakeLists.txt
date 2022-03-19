function(extra_step _name)
    ExternalProject_Add_Step(${_name} fullclean
        COMMAND ${EXEC} find <INSTALL_DIR>/src/${_name}-stamp -type f " ! -iname '*.cmake' " -size 0c -delete # remove 0 byte files which are stamp files
        ALWAYS TRUE
        EXCLUDE_FROM_MAIN TRUE
        COMMENT "Deleting all stamp files of ${_name} package"
    )

    ExternalProject_Add_Step(${_name} liteclean
        COMMAND ${EXEC} rm -f <INSTALL_DIR>/src/${_name}-stamp/${_name}-build
                              <INSTALL_DIR>/src/${_name}-stamp/${_name}-install
        ALWAYS TRUE
        EXCLUDE_FROM_MAIN TRUE
        COMMENT "Deleting build, install stamp files of ${_name} package"
    )
    ExternalProject_Add_StepTargets(${_name} fullclean liteclean)

endfunction()

function(cleanup _name _last_step)
    get_property(_build_in_source TARGET ${_name} PROPERTY _EP_BUILD_IN_SOURCE)
    get_property(_git_repository TARGET ${_name} PROPERTY _EP_GIT_REPOSITORY)
    get_property(_url TARGET ${_name} PROPERTY _EP_URL)

    if(_git_repository)
        if(_build_in_source)
            set(remove_cmd "git -C <SOURCE_DIR> clean -dfx")
        else()
            set(remove_cmd "rm -rf <BINARY_DIR>")
        endif()
    elseif(_url)
        set(remove_cmd "rm -rf <SOURCE_DIR> <BINARY_DIR>")
    endif()

    if(ALWAYS_REMOVE_BUILDFILES)
        ExternalProject_Add_Step(${_name} postremovebuild
            DEPENDEES ${_last_step}
            COMMAND ${EXEC} ${remove_cmd}
            LOG 1
            COMMENT "Deleting build directory of ${_name} package after install"
        )
    endif()

    ExternalProject_Add_Step(${_name} removebuild
        DEPENDEES fullclean
        COMMAND ${EXEC} ${remove_cmd}
        ALWAYS TRUE
        EXCLUDE_FROM_MAIN TRUE
        LOG 1
        COMMENT "Deleting build directory of ${_name} package"
    )

    ExternalProject_Add_Step(${_name} removeprefix
        COMMAND ${EXEC} rm -rf <INSTALL_DIR>
        ALWAYS TRUE
        EXCLUDE_FROM_MAIN TRUE
        COMMENT "Deleting everything about ${_name} package"
    )
    ExternalProject_Add_StepTargets(${_name} removeprefix removebuild)

endfunction()

function(force_rebuild_git _name)
    get_property(git_tag TARGET ${_name} PROPERTY _EP_GIT_TAG)
    get_property(stamp_dir TARGET ${_name} PROPERTY _EP_STAMP_DIR)

    if(NOT git_tag)
      set(git_tag "@{u}")
      set(pull COMMAND git pull)
    else()
      set(git_tag ${git_tag})
      set(pull "")
    endif()

    if(ENABLE_UPDATE)
        ExternalProject_Add_Step(${_name} force-update
            DEPENDEES download update
            DEPENDERS patch build install
            INDEPENDENT TRUE
            COMMAND git reset --hard ${git_tag}
            ${pull}
            WORKING_DIRECTORY <SOURCE_DIR>
            LOG 1
        )
    endif()

    if(EXISTS "${SINGLE_SOURCE_LOCATION}/${_name}/.git")
        ExternalProject_Add_Step(${_name} check-git
            DEPENDERS download
            INDEPENDENT TRUE
            WORKING_DIRECTORY ${stamp_dir}
            COMMAND ${CMAKE_COMMAND} -E copy ${_name}-gitinfo.txt ${_name}-gitclone-lastrun.txt
        )
    endif()
endfunction()

set_property(DIRECTORY PROPERTY EP_STEP_TARGETS download)

list(APPEND ep
    binutils
    mingw-w64
    mingw-w64-headers
    gcc
    mingw-w64-crt
    winpthreads
    gendef
    widl
)
foreach(package IN LISTS ep)
    if(NOT ${SINGLE_SOURCE_LOCATION} STREQUAL "")
        set(SOURCE_LOCATION "${SINGLE_SOURCE_LOCATION}/${package}")
    endif()
    include(${CMAKE_CURRENT_SOURCE_DIR}/${package}.cmake)
    set(SOURCE_LOCATION "")
endforeach()
list(LENGTH ep ep_length)
message(STATUS "Finish parsing ${ep_length} toolchain packages")
