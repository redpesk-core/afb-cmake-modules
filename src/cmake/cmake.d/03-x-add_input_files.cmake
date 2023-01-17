if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.6)

MACRO(filter_files VAR EXPR FILES)
	set(${VAR} ${FILES})
	list(FILTER ${VAR} INCLUDE REGEX ${EXPR})
ENDMACRO(filter_files)

else(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.6)
#--------------------------------------------------------------------------
# CMake 3.6 imported macros to simulate list(FILTER ...) subcommand
#--------------------------------------------------------------------------
MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
	FOREACH(arg_name ${arg_names})
		SET(${prefix}_${arg_name})
	ENDFOREACH(arg_name)
	FOREACH(option ${option_names})
		SET(${prefix}_${option} FALSE)
	ENDFOREACH(option)

	SET(current_arg_name DEFAULT_ARGS)
	SET(current_arg_list)
	FOREACH(arg ${ARGN})
		LIST_CONTAINS(is_arg_name ${arg} ${arg_names})
		IF (is_arg_name)
			SET(${prefix}_${current_arg_name} ${current_arg_list})
			SET(current_arg_name ${arg})
			SET(current_arg_list)
		ELSE (is_arg_name)
			LIST_CONTAINS(is_option ${arg} ${option_names})
			IF (is_option)
				SET(${prefix}_${arg} TRUE)
			ELSE (is_option)
				SET(current_arg_list ${current_arg_list} ${arg})
			ENDIF (is_option)
		ENDIF (is_arg_name)
	ENDFOREACH(arg)
	SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)

MACRO(LIST_CONTAINS var value)
	SET(${var})
	FOREACH (value2 ${ARGN})
		IF (${value} STREQUAL ${value2})
			SET(${var} TRUE)
		ENDIF (${value} STREQUAL ${value2})
	ENDFOREACH (value2)
ENDMACRO(LIST_CONTAINS)

MACRO(LIST_FILTER)
	PARSE_ARGUMENTS(LIST_FILTER "OUTPUT_VARIABLE" "" ${ARGV})
	# Check arguments.
	LIST(LENGTH LIST_FILTER_DEFAULT_ARGS LIST_FILTER_default_length)
	IF(${LIST_FILTER_default_length} EQUAL 0)
		MESSAGE(FATAL_ERROR "LIST_FILTER: missing list variable.")
	ENDIF(${LIST_FILTER_default_length} EQUAL 0)

	IF(${LIST_FILTER_default_length} EQUAL 1)
		MESSAGE(FATAL_ERROR "LIST_FILTER: missing regular expression variable.")
	ENDIF(${LIST_FILTER_default_length} EQUAL 1)

	# Reset output variable
	IF(NOT LIST_FILTER_OUTPUT_VARIABLE)
		SET(LIST_FILTER_OUTPUT_VARIABLE "LIST_FILTER_internal_output")
	ENDIF(NOT LIST_FILTER_OUTPUT_VARIABLE)
	SET(${LIST_FILTER_OUTPUT_VARIABLE})

	# Extract input list from arguments
	LIST(GET LIST_FILTER_DEFAULT_ARGS 0 LIST_FILTER_input_list)
	LIST(REMOVE_AT LIST_FILTER_DEFAULT_ARGS 0)
	FOREACH(LIST_FILTER_item ${${LIST_FILTER_input_list}})
		FOREACH(LIST_FILTER_regexp_var ${LIST_FILTER_DEFAULT_ARGS})
			FOREACH(LIST_FILTER_regexp ${${LIST_FILTER_regexp_var}})
				IF(${LIST_FILTER_item} MATCHES ${LIST_FILTER_regexp})
					LIST(APPEND ${LIST_FILTER_OUTPUT_VARIABLE} ${LIST_FILTER_item})
				ENDIF(${LIST_FILTER_item} MATCHES ${LIST_FILTER_regexp})
			ENDFOREACH(LIST_FILTER_regexp ${${LIST_FILTER_regexp_var}})
		ENDFOREACH(LIST_FILTER_regexp_var)
	ENDFOREACH(LIST_FILTER_item)

	# If OUTPUT_VARIABLE is not specified, overwrite the input list.
	IF(${LIST_FILTER_OUTPUT_VARIABLE} STREQUAL "LIST_FILTER_internal_output")
		SET(${LIST_FILTER_input_list} ${${LIST_FILTER_OUTPUT_VARIABLE}})
	ENDIF(${LIST_FILTER_OUTPUT_VARIABLE} STREQUAL "LIST_FILTER_internal_output")
ENDMACRO(LIST_FILTER)

MACRO(filter_files VAR EXPR FILES)
	set(ext_reg ${EXPR})
	set(${VAR} ${FILES})
	list_filter(${VAR} ext_reg)
ENDMACRO(filter_files)

endif(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.6)
#--------------------------------------------------------------------------

# Create custom target dedicated for DATA
macro(add_input_files INPUT_FILES)

	filter_files(XML_LIST "xml$" ${INPUT_FILES})
	filter_files(LUA_LIST "lua$" ${INPUT_FILES})
	filter_files(JSON_LIST "json$" ${INPUT_FILES})

	add_custom_target(${TARGET_NAME}
		DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	)

	if(XML_CHECKER_PRESENT)
		foreach(file ${XML_LIST})
			add_custom_command(TARGET ${TARGET_NAME}
				PRE_BUILD
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				COMMAND ${XML_CHECKER} ${file}
			)
		endforeach()
	endif()
	if(LUA_CHECKER_PRESENT)
		foreach(file ${LUA_LIST})
			add_custom_command(TARGET ${TARGET_NAME}
				PRE_BUILD
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				COMMAND ${LUA_CHECKER} ${file}
			)
		endforeach()
	endif()
	if(JSON_CHECKER_PRESENT)
		foreach(file ${JSON_LIST})
			add_custom_command(TARGET ${TARGET_NAME}
				PRE_BUILD
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				COMMAND ${JSON_CHECKER} ${file}
			)
		endforeach()
	endif()

	add_custom_command(
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
		DEPENDS ${INPUT_FILES}
		COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
		COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
		COMMAND cp -dr ${INPUT_FILES} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	)
endmacro()

