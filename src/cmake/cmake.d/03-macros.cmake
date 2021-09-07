###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Fulup Ar Foll <fulup@iot.bzh>
# contrib: Romain Forlot <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

###########################################################################
#
#  WARNING:
#     Do not change this cmake template
#     Customise your preferences in "./conf.d/cmake/config.cmake"
#
###########################################################################

MACRO(prevent_in_source_build)
	execute_process(COMMAND rm -rf ${CMAKE_SOURCE_DIR}/CMakeCache.txt
			${CMAKE_SOURCE_DIR}/CMakeCacheForScript.cmake
			${CMAKE_SOURCE_DIR}/CMakeFiles
			${CMAKE_SOURCE_DIR}/cmake_install.cmake)

	get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
	get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

	if(${srcdir} STREQUAL ${bindir})
		message(FATAL_ERROR "${Red}**** ERROR: You trying to build the project from the source directory or a previous build in-source occured. This isn't allowed, you have to clean CMakeCache.txt file from your source directory (${srcdir}), and build from a separate directory. ****\n")
	endif()
ENDMACRO(prevent_in_source_build)

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

# Generic useful macro
# -----------------------
macro(set_install_prefix)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND INSTALL_PREFIX)
		message("-- Overwrite the CMAKE default install prefix with ${INSTALL_PREFIX}")
		set(CMAKE_INSTALL_PREFIX ${INSTALL_PREFIX} CACHE PATH "Install prefix" FORCE)
	endif()

	# (BUG!!!) as PKG_CONFIG_PATH does not work [should be an env variable]
	# ---------------------------------------------------------------------
	set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/lib64/pkgconfig ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig CACHE PATH 'Prefix Path list used by pkgconfig module')
	set(LD_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib64 ${CMAKE_INSTALL_PREFIX}/lib CACHE PATH 'Path list where to search for libraries')
endmacro()

macro(PROJECT_TARGET_ADD TARGET_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_TARGETS ${TARGET_NAME})
	set(TARGET_NAME ${TARGET_NAME})
endmacro(PROJECT_TARGET_ADD)

macro(PROJECT_PKGDEP_ADD PKG_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_PKG_DEPS ${PKG_NAME})
endmacro(PROJECT_PKGDEP_ADD)

macro(defstr name value)
	add_definitions(-D${name}=${value})
endmacro(defstr)

macro(configure_files_in_dir dir)
	file(GLOB filelist "${dir}/*in")
	foreach(file ${filelist})
		get_filename_component(filename ${file} NAME)
		string(REGEX REPLACE "target" "${RSYNC_TARGET}" destinationfile ${filename})
		string(REGEX REPLACE ".in$" "" destinationfile ${destinationfile})
		configure_file(${file} ${CMAKE_CURRENT_BINARY_DIR}/target/${destinationfile})
		set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/target/${destinationfile}")
	endforeach()
endmacro(configure_files_in_dir)

# Create custom target dedicated for HTML5 and DATA AGL target type
macro(add_input_files INPUT_FILES)
	if(NOT DEFINED XML_FILES)
		set(ext_reg "xml$")
		set(XML_LIST ${INPUT_FILES})
		list_filter(XML_LIST ext_reg)
		execute_process(
			COMMAND which ${XML_CHECKER}
			RESULT_VARIABLE XML_CHECKER_PRESENT
			OUTPUT_QUIET ERROR_QUIET
		)
	endif()
	if(NOT DEFINED LUA_LIST)
		set(ext_reg "lua$")
		set(LUA_LIST ${INPUT_FILES})
		list_filter(LUA_LIST ext_reg)
		execute_process(
			COMMAND which ${LUA_CHECKER}
			RESULT_VARIABLE LUA_CHECKER_PRESENT
			OUTPUT_QUIET ERROR_QUIET
		)
	endif()
	if(NOT DEFINED JSON_FILES)
		set(ext_reg "json$")
		set(JSON_LIST ${INPUT_FILES})
		list_filter(JSON_LIST ext_reg)
		execute_process(
			COMMAND which ${JSON_CHECKER}
			RESULT_VARIABLE JSON_CHECKER_PRESENT
			OUTPUT_QUIET ERROR_QUIET
		)
	endif()

	# These are v3.6 subcommand. Not used as default for now as
	# many dev use Ubuntu 16.04 which have only 3.5 version
	#list(FILTER XML_LIST INCLUDE REGEX "xml$")
	#list(FILTER LUA_LIST INCLUDE REGEX "lua$")
	#list(FILTER JSON_LIST INCLUDE REGEX "json$")

	add_custom_target(${TARGET_NAME} ALL
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	)

	if(XML_CHECKER_PRESENT EQUAL 0)
		foreach(file ${XML_LIST})
			add_custom_command(TARGET ${TARGET_NAME}
				PRE_BUILD
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
				COMMAND ${XML_CHECKER} ${file}
			)
		endforeach()
	elseif(XML_LIST)
	add_custom_command(TARGET ${TARGET_NAME}
	PRE_BUILD
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --red "Warning: XML_CHECKER not found. Not verification made on files !")
	endif()
	if(LUA_CHECKER_PRESENT EQUAL 0)
		foreach(file ${LUA_LIST})
		add_custom_command(TARGET ${TARGET_NAME}
			PRE_BUILD
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMAND ${LUA_CHECKER} ${file}
		)
		endforeach()
	elseif(LUA_LIST)
		add_custom_command(TARGET ${TARGET_NAME}
			PRE_BUILD
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --red "Warning: LUA_CHECKER not found. Not verification made on files !")
	endif()
	if(JSON_CHECKER_PRESENT EQUAL 0)
		foreach(file ${JSON_LIST})
		add_custom_command(TARGET ${TARGET_NAME}
			PRE_BUILD
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMAND ${JSON_CHECKER} ${file}
		)
		endforeach()
	elseif(JSON_LIST)
	add_custom_command(TARGET ${TARGET_NAME}
	PRE_BUILD
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --red "Warning: JSON_CHECKER not found. Not verification made on files !")
	endif()

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	DEPENDS ${INPUT_FILES}
	COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	COMMAND cp -dr ${INPUT_FILES} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}
	)
endmacro()

# Set the name of the OPENAPI definition JSON file for binding v2
macro(set_openapi_filename openapi_filename)
	set(OPENAPI_DEF ${openapi_filename}
	    CACHE STRING "OpenAPI JSON file name used to generate binding header file before building a binding v2 target.")
endmacro()

# Common command to call inside project_targets_populate macro
macro(generate_one_populate_target OUTPUTFILES PKG_DESTDIR)
	add_custom_command(OUTPUT ${PKG_DESTDIR}/${OUTPUTFILES}
		DEPENDS ${BD}/${OUTPUTFILES}
		COMMAND mkdir -p ${PKG_DESTDIR}
		COMMAND touch ${PKG_DESTDIR}
		COMMAND cp -dr ${BD}/${OUTPUTFILES}/* ${PKG_DESTDIR} 2> /dev/null || cp -d ${BD}/${OUTPUTFILES} ${PKG_DESTDIR}
	)

	add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PKG_DESTDIR}/${OUTPUTFILES})
	add_dependencies(populate ${POPULE_PACKAGE_TARGET})
	add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
endmacro()

# To be call inside project_targets_populate macro
macro(afb_genskel)
	set (ARGSLIST ${ARGN})

	if ("${PROJECT_LANGUAGES}" MATCHES "CXX")
		list(APPEND ARGSLIST "--cpp")
	endif()

	if (OPENAPI_DEF)
		add_custom_command(OUTPUT ${SD}/${OPENAPI_DEF}.h
			DEPENDS ${SD}/${OPENAPI_DEF}.json
			COMMAND afb-genskel ${ARGSLIST} ${SD}/${OPENAPI_DEF}.json > ${SD}/${OPENAPI_DEF}.h
		)
		add_custom_target("${TARGET}_GENSKEL" DEPENDS ${SD}/${OPENAPI_DEF}.h
			COMMENT "Generating OpenAPI header file ${OPENAPI_DEF}.h")
		add_dependencies(${TARGET} "${TARGET}_GENSKEL")
	else()
		add_custom_command(OUTPUT ${SD}/${OUT}-apidef.h
			DEPENDS ${SD}/${OUT}-apidef.json
			COMMAND afb-genskel ${ARGSLIST} ${SD}/${OUT}-apidef.json > ${SD}/${OUT}-apidef.h
		)
		add_custom_target("${TARGET}_GENSKEL" DEPENDS ${SD}/${OUT}-apidef.h
			COMMENT "Generating OpenAPI header file ${OUT}-apidef.h")
		add_dependencies(${TARGET} "${TARGET}_GENSKEL")
	endif()
endmacro()

# Pre-packaging
macro(project_targets_populate)
	# Default Widget default directory
	set(PACKAGE_BINDIR  ${PROJECT_PKG_BUILD_DIR}/${BINDIR})
	set(PACKAGE_ETCDIR  ${PROJECT_PKG_BUILD_DIR}/${ETCDIR})
	set(PACKAGE_LIBDIR  ${PROJECT_PKG_BUILD_DIR}/${LIBDIR})
	set(PACKAGE_HTTPDIR ${PROJECT_PKG_BUILD_DIR}/${HTTPDIR})
	set(PACKAGE_DATADIR ${PROJECT_PKG_BUILD_DIR}/${DATADIR})
	# Default test Widget default directory
	string(REGEX REPLACE "/([^/]*)$" "/\\1-test" PROJECT_PKG_TEST_DIR "${PROJECT_PKG_BUILD_DIR}")
	set(PACKAGE_TEST_BINDIR  ${PROJECT_PKG_TEST_DIR}/${BINDIR})
	set(PACKAGE_TEST_ETCDIR  ${PROJECT_PKG_TEST_DIR}/${ETCDIR})
	set(PACKAGE_TEST_LIBDIR  ${PROJECT_PKG_TEST_DIR}/${LIBDIR})
	set(PACKAGE_TEST_HTTPDIR ${PROJECT_PKG_TEST_DIR}/${HTTPDIR})
	set(PACKAGE_TEST_DATADIR ${PROJECT_PKG_TEST_DIR}/${DATADIR})

	add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}
			   COMMAND mkdir -p ${PROJECT_PKG_BUILD_DIR})
	add_custom_command(OUTPUT ${PACKAGE_BINDIR}
			   COMMAND mkdir -p ${PACKAGE_BINDIR}
			   DEPENDS ${PROJECT_PKG_BUILD_DIR})
	add_custom_command(OUTPUT ${PACKAGE_ETCDIR}
			   COMMAND mkdir -p ${PACKAGE_ETCDIR}
			   DEPENDS ${PROJECT_PKG_BUILD_DIR})
	add_custom_command(OUTPUT ${PACKAGE_LIBDIR}
			   COMMAND mkdir -p ${PACKAGE_LIBDIR}
			   DEPENDS ${PROJECT_PKG_BUILD_DIR})
	add_custom_command(OUTPUT ${PACKAGE_HTTPDIR}
			   COMMAND mkdir -p ${PACKAGE_HTTPDIR}
			   DEPENDS ${PROJECT_PKG_BUILD_DIR})
	add_custom_command(OUTPUT ${PACKAGE_DATADIR}
			   COMMAND mkdir -p ${PACKAGE_DATADIR}
			   DEPENDS ${PROJECT_PKG_BUILD_DIR})

	add_custom_target(prepare_package
				DEPENDS ${PROJECT_PKG_BUILD_DIR}
					${PACKAGE_BINDIR}
					${PACKAGE_ETCDIR}
					${PACKAGE_LIBDIR}
					${PACKAGE_HTTPDIR}
					${PACKAGE_DATADIR})

	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_DIR}
			   COMMAND mkdir -p ${PROJECT_PKG_TEST_DIR})
	add_custom_command(OUTPUT ${PACKAGE_TEST_BINDIR}
			   COMMAND mkdir -p ${PACKAGE_TEST_BINDIR}
			   DEPENDS ${PROJECT_PKG_TEST_DIR})
	add_custom_command(OUTPUT ${PACKAGE_TEST_ETCDIR}
			   COMMAND mkdir -p ${PACKAGE_TEST_ETCDIR}
			   DEPENDS ${PROJECT_PKG_TEST_DIR})
	add_custom_command(OUTPUT ${PACKAGE_TEST_LIBDIR}
			   COMMAND mkdir -p ${PACKAGE_TEST_LIBDIR}
			   DEPENDS ${PROJECT_PKG_TEST_DIR})
	add_custom_command(OUTPUT ${PACKAGE_TEST_HTTPDIR}
			   COMMAND mkdir -p ${PACKAGE_TEST_HTTPDIR}
			   DEPENDS ${PROJECT_PKG_TEST_TEST_DIR})
	add_custom_command(OUTPUT ${PACKAGE_TEST_DATADIR}
			   COMMAND mkdir -p ${PACKAGE_TEST_DATADIR}
			   DEPENDS ${PROJECT_PKG_TEST_DIR})

	add_custom_target(prepare_package_test
				DEPENDS ${PROJECT_PKG_TEST_DIR}
					${PACKAGE_TEST_BINDIR}
					${PACKAGE_TEST_ETCDIR}
					${PACKAGE_TEST_LIBDIR}
					${PACKAGE_TEST_HTTPDIR}
					${PACKAGE_TEST_DATADIR})

	add_custom_target(populate)
	add_dependencies(populate prepare_package prepare_package_test)

	# Dirty trick to define a default INSTALL command for app-templates handled
	# targets
	INSTALL(CODE "execute_process(COMMAND make populate)")
	if(NO_DEDICATED_INSTALL_DIR)
		INSTALL(DIRECTORY ${PROJECT_PKG_BUILD_DIR}/
			DESTINATION ${CMAKE_INSTALL_PREFIX}
			USE_SOURCE_PERMISSIONS
		)
		INSTALL(DIRECTORY ${PROJECT_PKG_TEST_DIR}/
			DESTINATION ${CMAKE_INSTALL_PREFIX}/test
			USE_SOURCE_PERMISSIONS
		)
	else()
		INSTALL(DIRECTORY ${PROJECT_PKG_BUILD_DIR}/
			DESTINATION ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}
			USE_SOURCE_PERMISSIONS
		)
		INSTALL(DIRECTORY ${PROJECT_PKG_TEST_DIR}/
			DESTINATION ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}-test
			USE_SOURCE_PERMISSIONS
		)
	endif()

	get_property(PROJECT_TARGETS GLOBAL PROPERTY PROJECT_TARGETS)
	foreach(TARGET ${PROJECT_TARGETS})
		# Declaration of a custom command that will populate widget tree with the target
		set(POPULE_PACKAGE_TARGET "project_populate_${TARGET}")
		get_target_property(TYPE ${TARGET} TYPE)

		if(${TYPE} STREQUAL "STATIC_LIBRARY" OR
		   ${TYPE} STREQUAL "MODULE_LIBRARY" OR
		   ${TYPE} STREQUAL "SHARED_LIBRARY" OR
		   ${TYPE} STREQUAL "INTERFACE_LIBRARY" OR
		   ${TYPE} STREQUAL "EXECUTABLE"
		)
			foreach(linked_lib ${link_libraries})
				if(NOT ${linked_lib} STREQUAL ${TARGET})
					set_property(TARGET ${TARGET} APPEND PROPERTY LINK_LIBRARIES ${linked_lib})
				endif()
			endforeach(linked_lib ${${link_libraries}})
		endif()
		get_target_property(SUBTYPE ${TARGET} LABELS)
		if(SUBTYPE)
			get_target_property(P ${TARGET} PREFIX)
			get_target_property(S ${TARGET} SUFFIX)
			get_target_property(BD ${TARGET} BINARY_DIR)
			get_target_property(SD ${TARGET} SOURCE_DIR)
			get_target_property(OUT ${TARGET} OUTPUT_NAME)

			if(OUT MATCHES "NOTFOUND$")
				set(OUT ${TARGET})
			endif()

			if(P MATCHES "NOTFOUND$")
				if (${SUBTYPE} STREQUAL "LIBRARY" OR
				    ${SUBTYPE} MATCHES "^BINDINGV?.?$")
					set(P "lib")
				else()
					set(P "")
				endif()
			endif()

			get_target_property(IMPPATH ${TARGET} IMPORTED_LOCATION)
			if(${SUBTYPE} STREQUAL "LIBRARY")
				unset(BD)
				generate_one_populate_target(${IMPPATH} ${PACKAGE_LIBDIR})
			elseif(${SUBTYPE} STREQUAL "TEST-LIBRARY")
				unset(BD)
				generate_one_populate_target(${IMPPATH} ${PACKAGE_TEST_LIBDIR})
			elseif(${SUBTYPE} STREQUAL "PLUGIN")
				if(NOT S)
					set(S ".ctlso")
				endif()
				generate_one_populate_target(${P}${OUT}${S} "${PACKAGE_LIBDIR}/plugins")
			elseif(${SUBTYPE} STREQUAL "TEST-PLUGIN")
				if(NOT S)
					set(S ".ctlso")
				endif()
				generate_one_populate_target(${P}${OUT}${S} "${PACKAGE_TEST_LIBDIR}/plugins")
			elseif(${SUBTYPE} STREQUAL "BINDING")
				if(NOT S)
					set(S ".so")
				endif()
				list(APPEND BINDINGS_LIST "${P}${OUT}${S}")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_TARGET_PROPERTIES(${TARGET} PROPERTIES
					LINK_FLAGS  ${BINDINGS_LINK_FLAG}
				)
			elseif(${SUBTYPE} STREQUAL "BINDINGV2")
				if(NOT S)
					set(S ".so")
				endif()
				afb_genskel("-2")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_TARGET_PROPERTIES(${TARGET} PROPERTIES
					LINK_FLAGS  ${BINDINGS_LINK_FLAG}
				)
			elseif(${SUBTYPE} STREQUAL "BINDINGV3")
				if(NOT S)
					set(S ".so")
				endif()
				afb_genskel("-3")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_TARGET_PROPERTIES(${TARGET} PROPERTIES
					LINK_FLAGS  ${BINDINGS_LINK_FLAG}
				)
			elseif(${SUBTYPE} STREQUAL "EXECUTABLE")
				if(NOT S)
					set(S "")
				endif()
				if(NOT OUT AND IMPPATH)
					unset(BD)
					generate_one_populate_target(${IMPPATH} ${PACKAGE_BINDIR})
				else()
					generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_BINDIR})
				endif()
			elseif(${SUBTYPE} STREQUAL "TEST-EXECUTABLE")
				if(NOT S)
					set(S "")
				endif()
				if(NOT OUT AND IMPPATH)
					unset(BD)
					generate_one_populate_target(${IMPPATH} ${PACKAGE_TEST_BINDIR})
				else()
					generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_TEST_BINDIR})
				endif()
			elseif(${SUBTYPE} STREQUAL "HTDOCS")
				generate_one_populate_target(${P}${OUT} ${PACKAGE_HTTPDIR})
			elseif(${SUBTYPE} STREQUAL "TEST-HTDOCS")
				generate_one_populate_target(${P}${OUT} ${PACKAGE_HTTPDIR})
			elseif(${SUBTYPE} STREQUAL "DATA" )
				generate_one_populate_target(${TARGET} ${PACKAGE_DATADIR})
			elseif(${SUBTYPE} STREQUAL "TEST-DATA")
				generate_one_populate_target(${TARGET} ${PACKAGE_TEST_DATADIR})
			elseif(${SUBTYPE} STREQUAL "BINDING-CONFIG" )
				generate_one_populate_target(${TARGET} ${PACKAGE_ETCDIR})
			elseif(${SUBTYPE} STREQUAL "TEST-CONFIG")
				generate_one_populate_target(${TARGET} ${PACKAGE_TEST_ETCDIR})
			endif()
		elseif("${CMAKE_BUILD_TYPE}" MATCHES "[Dd][Ee][Bb][Uu][Gg]")
			MESSAGE("${BoldBlue}.. Notice: ${TARGET} ignored when packaging.${ColourReset}")
		endif()
	endforeach()
endmacro(project_targets_populate)

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

macro(wgt_package_build)
# check if widget is required
if(WIDGET_TYPE)
	# checks
	if(NOT EXISTS ${WIDGET_CONFIG_TEMPLATE})
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build widget file.
You need a config.xml template: please specify WIDGET_CONFIG_TEMPLATE correctly.${ColourReset}")
	endif()

	# default test template
	if(NOT EXISTS ${TEST_WIDGET_CONFIG_TEMPLATE})
		MESSAGE("${BoldBlue}-- Notice: Using default test widget configuration's file.
-- If you want to use a customized test-config.xml template then specify TEST_WIDGET_CONFIG_TEMPLATE in your config.cmake file.${ColourReset}")

		set(TEST_WIDGET_CONFIG_TEMPLATE "${PROJECT_APP_TEMPLATES_DIR}/test-wgt/test-config.xml.in"
		    CACHE PATH "Path to the test widget config file template (test-config.xml.in)")
	endif()

	# the targets
	set(widget_files_items)
	set(test_widget_files_items)

	# widget entry point
	if(NOT WIDGET_ENTRY_POINT)
		set(WIDGET_ENTRY_POINT lib)
	endif()

	# widget name
	if(NOT ${CMAKE_BUILD_TYPE} STREQUAL "RELEASE")
		string(TOLOWER "${PROJECT_NAME}-${CMAKE_BUILD_TYPE}" WGT_NAME)
	else()
		string(TOLOWER "${PROJECT_NAME}" WGT_NAME)
	endif()

	# icon of widget
	if(NOT DEFINED PROJECT_ICON)
		set(PROJECT_ICON icon.png)
		if( ${WIDGET_TYPE} MATCHES "agl.native")
			set(ICON_PATH ${PKG_APP_TEMPLATE_DIR}/wgt/icon-native.png)
		elseif( ${WIDGET_TYPE} MATCHES "agl.service")
			set(ICON_PATH ${PKG_APP_TEMPLATE_DIR}/wgt/icon-service.png)
		elseif( ${WIDGET_TYPE} MATCHES "x-executable")
			set(ICON_PATH ${PKG_APP_TEMPLATE_DIR}/wgt/icon-qml.png)
		elseif( ${WIDGET_TYPE} MATCHES "text/html")
			set(ICON_PATH ${PKG_APP_TEMPLATE_DIR}/wgt/icon-html5.png)
		endif()
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/${WIDGET_ICON}")
		set(ICON_PATH "${CMAKE_SOURCE_DIR}/${WIDGET_ICON}")
	elseif(EXISTS "${WIDGET_ICON}")
		set(ICON_PATH "${WIDGET_ICON}")
	else()
		set(ICON_PATH ${PROJECT_APP_TEMPLATES_DIR}/wgt/icon-default.png)
	endif()

	# populate icon
	add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/${PROJECT_ICON}
		COMMAND cp -d ${ICON_PATH} ${PROJECT_PKG_BUILD_DIR}/${PROJECT_ICON}
		DEPENDS ${PROJECT_PKG_BUILD_DIR}
	)
	list(APPEND widget_files_items ${PROJECT_PKG_BUILD_DIR}/${PROJECT_ICON})
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_DIR}/${PROJECT_ICON}
		COMMAND cp -d ${ICON_PATH} ${PROJECT_PKG_TEST_DIR}/${PROJECT_ICON}
		DEPENDS ${PROJECT_PKG_TEST_DIR}
	)
	list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_DIR}/${PROJECT_ICON})

	# populate wgt/etc
	add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/etc
		COMMAND mkdir -p ${PROJECT_PKG_BUILD_DIR}/etc)
	file(GLOB PROJECT_CONF_FILES "${TEMPLATE_DIR}/etc/*")
	if(${PROJECT_CONF_FILES})
		add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/etc
			COMMAND cp -dr ${TEMPLATE_DIR}/etc/* ${PROJECT_PKG_BUILD_DIR}/etc
			APPEND
		)
		list(APPEND widget_files_items ${PROJECT_PKG_BUILD_DIR}/etc)
	endif(${PROJECT_CONF_FILES})

	# instanciate config.xml
	add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/config.xml
		COMMAND ${CMAKE_COMMAND} -DINFILE=${WIDGET_CONFIG_TEMPLATE} -DOUTFILE=${PROJECT_PKG_BUILD_DIR}/config.xml
			-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
			-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
	)
	list(APPEND widget_files_items ${PROJECT_PKG_BUILD_DIR}/config.xml)
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_DIR}/config.xml
		COMMAND ${CMAKE_COMMAND} -DINFILE=${TEST_WIDGET_CONFIG_TEMPLATE} -DOUTFILE=${PROJECT_PKG_TEST_DIR}/config.xml
			-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
			-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
	)
	list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_DIR}/config.xml)

	# add test launcher
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_DIR}/bin
		COMMAND mkdir -p ${PROJECT_PKG_TEST_DIR}/bin
	)
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_DIR}/bin/launcher
		COMMAND cp -d ${PROJECT_APP_TEMPLATES_DIR}/test-wgt/launcher.sh.in ${PROJECT_PKG_TEST_DIR}/bin/launcher
		DEPENDS ${PROJECT_PKG_TEST_DIR}/bin
	)
	list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_DIR}/bin/launcher)

	# create package
	find_program(wgtpkgCMD "wgtpkg-pack")
	if(wgtpkgCMD)
		set(packCMD ${wgtpkgCMD} "-f" "-o" "${WGT_NAME}.wgt" ${PROJECT_PKG_BUILD_DIR})
		set(packCMDTest ${wgtpkgCMD} "-f" "-o" "${WGT_NAME}-test.wgt" ${PROJECT_PKG_TEST_DIR})
	else()
		find_program(wgtpkgCMD "zip")
		if(wgtpkgCMD)
			set(packCMD ${CMAKE_COMMAND} -E cmake_echo_color --yellow "Warning: Widget will be built using Zip, NOT using the Application Framework widget pack command." && cd ${PROJECT_PKG_BUILD_DIR} && ${wgtpkgCMD} -r "../${WGT_NAME}.wgt" "*")
			set(packCMDTest ${CMAKE_COMMAND} -E cmake_echo_color --yellow "Warning: Test widget will be built using Zip, NOT using the Application Framework widget pack command." && cd ${PROJECT_PKG_TEST_DIR} && ${wgtpkgCMD} -r "../${WGT_NAME}-test.wgt" "*")
		else()
			set(packCMD ${CMAKE_COMMAND} -E cmake_echo_color --red "Error: No utility found to build a widget. Either install wgtpkg-pack from App Framework or zip command" && false)
		endif()
	endif()

	add_custom_command(OUTPUT ${WGT_NAME}.wgt
		DEPENDS ${PROJECT_TARGETS}
		COMMAND ${packCMD}
	)

	add_custom_command(OUTPUT ${WGT_NAME}-test.wgt
		DEPENDS ${PROJECT_TARGETS}
		COMMAND ${packCMDTest}
	)

	add_custom_target(widget_files           DEPENDS populate ${PROJECT_TARGETS} ${widget_files_items})
	add_custom_target(widget                 DEPENDS widget_files ${WGT_NAME}.wgt)
	add_custom_target(test_widget_files      DEPENDS populate ${PROJECT_TARGETS} ${test_widget_files_items})
	add_custom_target(test_widget            DEPENDS test_widget_files ${WGT_NAME}-test.wgt)
	if(${BUILD_TEST_WGT})
		add_dependencies(widget test_widget)
	endif()

	set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/${WGT_NAME}.wgt")
	set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/${WGT_NAME}-test.wgt")

	if(NOT RSYNC_TARGET)
		message ("${Yellow}.. Warning: RSYNC_TARGET not defined 'make widget-target-install' not instanciated${ColourReset}")
		add_custom_target(widget-target-install
			COMMENT "${Red}*** Fatal: RSYNC_TARGET RSYNC_PREFIX environment variables required with 'make widget-target-install'${ColourReset}"
			COMMAND exit -1
		)
	else()
		configure_files_in_dir(${TEMPLATE_DIR})
		add_custom_target(widget-target-install
			DEPENDS widget
			COMMAND chmod +x ${CMAKE_CURRENT_BINARY_DIR}/target/install-wgt-on-${RSYNC_TARGET}.sh
			COMMAND ${CMAKE_CURRENT_BINARY_DIR}/target/install-wgt-on-${RSYNC_TARGET}.sh
		)
	endif()

	if(PACKAGE_MESSAGE)
		add_custom_command(TARGET widget
			POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${PACKAGE_MESSAGE}")
	endif()
else()
	#MESSAGE(FATAL_ERROR "WIDGET_TYPE must be set in your config.cmake.\neg.: set(WIDGET_TYPE application/vnd.agl.service)")
endif()
endmacro(wgt_package_build)

macro(rpm_package_build)
	add_custom_command(OUTPUT ${NPKG_PROJECT_NAME}.spec
		DEPENDS ${PROJECT_TARGETS}
				archive
				packaging
		COMMAND rpmbuild --define=\"%_sourcedir ${PROJECT_PKG_ENTRY_POINT}\" -ba  ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}.spec
	)

	add_custom_target(rpm DEPENDS ${NPKG_PROJECT_NAME}.spec)
	add_dependencies(rpm populate packaging)

	if(PACKAGE_MESSAGE)
	add_custom_command(TARGET rpm
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${PACKAGE_MESSAGE}")
	endif()
endmacro(rpm_package_build)

macro(project_package_build)
	if(EXISTS ${TEMPLATE_DIR})
		wgt_package_build()
	endif()
endmacro(project_package_build)

macro(project_subdirs_add)
	set (ARGSLIST ${ARGN})
	list(LENGTH ARGSLIST ARGSNUM)
	if(${ARGSNUM} GREATER 0)
		file(GLOB filelist "${ARGV0}")
	else()
		file(GLOB filelist "*")
	endif()

	foreach(filename ${filelist})
		if(NOT "${filename}" MATCHES "^/.*/_[^/]*$" )
			if(EXISTS "${filename}/CMakeLists.txt")
				add_subdirectory(${filename})
			elseif(${filename} MATCHES "^.*\\.cmake$")
				include(${filename})
			endif()
		endif()

	endforeach()
endmacro(project_subdirs_add)

# Print developer helper message when build is done
# -------------------------------------------------------
macro(project_closing_msg)
	get_property(PROJECT_TARGETS_SET GLOBAL PROPERTY PROJECT_TARGETS SET)
	get_property(PROJECT_TARGETS GLOBAL PROPERTY PROJECT_TARGETS)
	if(CLOSING_MESSAGE AND ${PROJECT_TARGETS_SET})
		add_custom_target(${PROJECT_NAME}_build_done ALL
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan "++ ${CLOSING_MESSAGE}"
		)
		add_dependencies(${PROJECT_NAME}_build_done
			${PROJECT_TARGETS} populate)
	endif()
endmacro()

macro(info_verb_generate TARGET_NAME)
	set( JSON_INFO_C ${CMAKE_CURRENT_BINARY_DIR}/json_info.c)
	target_sources(${TARGET_NAME} PUBLIC ${JSON_INFO_C})
	add_custom_command(
		OUTPUT json_info.c
		COMMAND echo 'const char * info_verbS=\"\\' > ${JSON_INFO_C}
		COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/info_verb.json | sed -e 's/$$/\\\\/' -e 's/\"/\\\\\"/g' >> ${JSON_INFO_C}
		COMMAND echo '\\n\"\;' >> ${JSON_INFO_C}
		DEPENDS info_verb.json
	)

endmacro()