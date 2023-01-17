# Define some checker binaries to verify input DATA files
# to be included in package. Schema aren't checked for now.
# Dummy checker about JSON.
set(LUA_CHECKER "luac" "-p" CACHE STRING "LUA compiler")
set(XML_CHECKER "xmllint" CACHE STRING "XML linter")
set(JSON_CHECKER "" CACHE STRING "JSON linter")

macro(checker_presence NAME)
	if(${NAME}_CHECKER)
		execute_process(
			COMMAND which ${${NAME}_CHECKER}
			RESULT_VARIABLE ${NAME}_CHECKER_PRESENT
			OUTPUT_QUIET ERROR_QUIET
		)
		if(NOT (${NAME}_CHECKER_PRESENT EQUAL 0))
			add_custom_target(TARGET_${NAME}_CHECKER_NOT_FOUND ALL
				COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --red
					"Warning: ${NAME} checker not found. No verification of ${NAME} files !")

		endif()
	endif()
	if(${NAME}_CHECKER_PRESENT EQUAL 0)
		set(${NAME}_CHECKER_PRESENT YES)
	else()
		set(${NAME}_CHECKER_PRESENT NO)
	endif()
endmacro(checker_presence)

checker_presence(XML)
checker_presence(LUA)
checker_presence(JSON)
