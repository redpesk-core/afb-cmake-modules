macro(remote_targets_populate)
	if (DEFINED ENV{RSYNC_TARGET})
		set (RSYNC_TARGET $ENV{RSYNC_TARGET})
	endif()
	if (DEFINED ENV{RSYNC_PREFIX})
		set (RSYNC_PREFIX $ENV{RSYNC_PREFIX})
	endif()

	set(
		REMOTE_LAUNCH "Test on target with: ${CMAKE_CURRENT_BINARY_DIR}/target/start-on-${RSYNC_TARGET}.sh"
		CACHE STRING "Command to start ${PROJECT_NAME} on remote target ${RSYNC_TARGET}"
	)

	if(NOT RSYNC_TARGET OR NOT RSYNC_PREFIX)
		message ("${Yellow}.. Warning: RSYNC_TARGET RSYNC_PREFIX not defined 'make remote-target-populate' not instanciated${ColourReset}")
		add_custom_target(remote-target-populate
			COMMENT "${Red}*** Fatal: RSYNC_TARGET RSYNC_PREFIX environment variables required with 'make remote-target-populate'${ColourReset}"
			COMMAND exit -1
		)
	else()
		set(BINDINGS_REGEX "not_set")
		if(DEFINED BINDINGS_LIST)
			list(LENGTH BINDINGS_LIST BINDINGS_LIST_LENGTH)
			if(BINDINGS_LIST_LENGTH EQUAL 1)
				list(GET BINDINGS_LIST 0 BINDINGS_REGEX)
				string(APPEND BINDINGS_REGEX ".so")
			elseif(BINDINGS_LIST_LENGTH GREATER 1)
				foreach(B IN LISTS BINDINGS_LIST)
					STRING(APPEND BINDINGS_STR "${B}|")
				endforeach()
					STRING(REGEX REPLACE "^(.*)\\|$" "(\\1).so" BINDINGS_REGEX ${BINDINGS_STR})
			endif()
		endif()

		configure_files_in_dir(${TEMPLATE_DIR})
		configure_files_in_dir(${TEMPLATE_DIR})

		add_custom_target(remote-target-populate
			COMMAND chmod +x ${CMAKE_CURRENT_BINARY_DIR}/target/*.sh
			COMMAND rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --archive --delete ${PROJECT_PKG_BUILD_DIR}/ ${RSYNC_TARGET}:${RSYNC_PREFIX}/${PROJECT_NAME}
		)

		add_custom_command(TARGET remote-target-populate
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --green --bold ${REMOTE_LAUNCH}
		)

		add_dependencies(remote-target-populate populate)
	endif()
endmacro(remote_targets_populate)

