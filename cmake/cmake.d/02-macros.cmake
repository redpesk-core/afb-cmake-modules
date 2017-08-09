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

#--------------------------------------------------------------------------
#  WARNING:
#     Do not change this cmake template
#     Customise your preferences in "./conf.d/cmake/config.cmake"
#--------------------------------------------------------------------------
# Generic useful macro
# -----------------------
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

# Pre-packaging
macro(project_targets_populate)
	# Default Widget default directory
	set(PACKAGE_BINDIR  ${PROJECT_PKG_BUILD_DIR}/bin)
	set(PACKAGE_ETCDIR  ${PROJECT_PKG_BUILD_DIR}/etc)
	set(PACKAGE_LIBDIR  ${PROJECT_PKG_BUILD_DIR}/lib)
	set(PACKAGE_HTTPDIR ${PROJECT_PKG_BUILD_DIR}/htdocs)
	set(PACKAGE_DATADIR ${PROJECT_PKG_BUILD_DIR}/data)

	add_custom_command(OUTPUT ${PACKAGE_BINDIR} ${PACKAGE_ETCDIR} ${PACKAGE_LIBDIR} ${PACKAGE_HTTPDIR} ${PACKAGE_DATADIR}
		COMMAND mkdir -p ${PACKAGE_BINDIR} ${PACKAGE_ETCDIR} ${PACKAGE_LIBDIR} ${PACKAGE_HTTPDIR} ${PACKAGE_DATADIR})
	add_custom_target(populate DEPENDS ${PACKAGE_BINDIR} ${PACKAGE_ETCDIR} ${PACKAGE_LIBDIR} ${PACKAGE_HTTPDIR} ${PACKAGE_DATADIR})
		get_property(PROJECT_TARGETS GLOBAL PROPERTY PROJECT_TARGETS)
	foreach(TARGET ${PROJECT_TARGETS})
		get_target_property(T ${TARGET} LABELS)
		if(T)
			# Declaration of a custom command that will populate widget tree with the target
			set(POPULE_PACKAGE_TARGET "project_populate_${TARGET}")

			get_target_property(P ${TARGET} PREFIX)
			get_target_property(BD ${TARGET} BINARY_DIR)
			get_target_property(SD ${TARGET} SOURCE_DIR)
			get_target_property(OUT ${TARGET} OUTPUT_NAME)

			if(P MATCHES "NOTFOUND$")
				if (${T} STREQUAL "BINDING")
					set(P "lib")
				else()
					set(P "")
				endif()
			endif()

			if(${T} STREQUAL "BINDING")
				list(APPEND BINDINGS_LIST "${P}${OUT}")
				add_custom_command(OUTPUT ${PACKAGE_LIBDIR}/${P}${OUT}.so
					DEPENDS ${BD}/${P}${OUT}.so
					COMMAND mkdir -p ${PACKAGE_LIBDIR}
					COMMAND cp ${BD}/${P}${OUT}.so ${PACKAGE_LIBDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_LIBDIR}/${P}${OUT}.so)
				add_dependencies(populate ${POPULE_PACKAGE_TARGET})
				add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
			elseif(${T} STREQUAL "BINDINGV2")
				add_custom_command(OUTPUT ${PACKAGE_LIBDIR}/${P}${OUT}.so
					DEPENDS ${BD}/${P}${OUT}.so
					COMMAND mkdir -p ${PACKAGE_LIBDIR}
					COMMAND cp ${BD}/${P}${OUT}.so ${PACKAGE_LIBDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_LIBDIR}/${P}${OUT}.so)

				add_custom_command(OUTPUT ${SD}/${P}${OUT}.h
					DEPENDS ${SD}/${P}${OUT}.json
					COMMAND afb-genskel ${SD}/${P}${OUT}.json > ${SD}/${P}${OUT}.h
				)
				add_custom_target("${TARGET}_GENSKEL" DEPENDS ${SD}/${P}${OUT}.h)
				add_dependencies(${TARGET} "${TARGET}_GENSKEL")
			elseif(${T} STREQUAL "EXECUTABLE")
				add_custom_command(OUTPUT ${PACKAGE_BINDIR}/${P}${OUT}
					DEPENDS ${BD}/${P}${OUT}
					COMMAND mkdir -p ${PACKAGE_BINDIR}
					COMMAND cp ${BD}/${P}${OUT} ${PACKAGE_BINDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_BINDIR}/${P}${OUT})
				add_dependencies(populate ${POPULE_PACKAGE_TARGET})
				add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
			elseif(${T} STREQUAL "HTDOCS")
				add_custom_command(OUTPUT ${PACKAGE_HTTPDIR}-xx
					DEPENDS ${BD}/${P}${OUT}
					COMMAND mkdir -p ${PACKAGE_HTTPDIR}
					COMMAND touch ${PACKAGE_HTTPDIR}
					COMMAND cp -r ${BD}/${P}${OUT}/* ${PACKAGE_HTTPDIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_HTTPDIR}-xx)
				add_dependencies(populate ${POPULE_PACKAGE_TARGET})
				add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
			elseif(${T} STREQUAL "DATA")
				add_custom_command(OUTPUT ${PACKAGE_DATADIR}-xx
					DEPENDS ${BD}/${P}${OUT}
					COMMAND mkdir -p ${PACKAGE_DATADIR}
					COMMAND touch ${PACKAGE_DATADIR}
					COMMAND cp -r ${BD}/${P}${OUT}/* ${PACKAGE_DATADIR}
				)
				add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PACKAGE_DATADIR}-xx)
				add_dependencies(populate ${POPULE_PACKAGE_TARGET})
				add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
			endif(${T} STREQUAL "BINDING")
		elseif(${CMAKE_BUILD_TYPE} MATCHES "[Dd][Ee][Bb][Uu][Gg]")
			MESSAGE(".. Warning: ${TARGET} ignored when packaging.")
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

		configure_files_in_dir(${SSH_TEMPLATE_DIR})
		configure_files_in_dir(${GDB_TEMPLATE_DIR})

		add_custom_target(remote-target-populate
			COMMAND chmod +x ${CMAKE_CURRENT_BINARY_DIR}/target/*.sh
			COMMAND rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --archive --delete ${PROJECT_PKG_BUILD_DIR}/ ${RSYNC_TARGET}:${RSYNC_PREFIX}/${PROJECT_NAME}
			COMMENT "${REMOTE_LAUNCH}"
		)
		add_dependencies(remote-target-populate populate)
	endif()
endmacro(remote_targets_populate)

macro(wgt_package_build)
	if(NOT EXISTS ${WIDGET_CONFIG_TEMPLATE})
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build widget file.\nYou need a config.xml template: please specify WIDGET_CONFIG_TEMPLATE correctly.${ColourReset}")
	endif()
	if(NOT EXISTS ${WGT_TEMPLATE_DIR}/icon-default.png)
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build widget file.\nYou need ${PROJECT_ICON} file in ${WGT_TEMPLATE_DIR} folder.${ColourReset}")
	endif()
    if(NOT WIDGET_TYPE)
        MESSAGE(FATAL_ERROR "WIDGET_TYPE must be set in your config.cmake.\neg.: set(WIDGET_TYPE application/vnd.agl.service)")
    endif()

	if(NOT WIDGET_ENTRY_POINT)
		set(WIDGET_ENTRY_POINT lib)
	endif()

	add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/config.xml
		COMMAND ${CMAKE_COMMAND} -DINFILE=${WIDGET_CONFIG_TEMPLATE} -DOUTFILE=${PROJECT_PKG_BUILD_DIR}/config.xml -DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
		COMMAND cp ${WGT_TEMPLATE_DIR}/icon-default.png ${PROJECT_PKG_BUILD_DIR}/${PROJECT_ICON}

	)
	add_custom_target(packaging_wgt DEPENDS ${PROJECT_PKG_BUILD_DIR}/config.xml)

	# Fulup ??? copy any extra file in wgt/etc into populate package before building the widget
	file(GLOB PROJECT_CONF_FILES "${WGT_TEMPLATE_DIR}/etc/*")
	if(${PROJECT_CONF_FILES})
		file(COPY "${WGT_TEMPLATE_DIR}/etc/*" DESTINATION ${PROJECT_PKG_BUILD_DIR}/etc/)
	endif(${PROJECT_CONF_FILES})

	add_custom_command(OUTPUT ${PROJECT_NAME}.wgt
		DEPENDS ${PROJECT_TARGETS}
		COMMAND wgtpkg-pack -f -o ${PROJECT_NAME}.wgt ${PROJECT_PKG_BUILD_DIR}
	)

	add_custom_target(widget DEPENDS ${PROJECT_NAME}.wgt)
	add_dependencies(widget populate packaging_wgt)
	set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.wgt")

	if(NOT RSYNC_TARGET)
		message ("${Yellow}.. Warning: RSYNC_TARGET not defined 'make widget-target-install' not instanciated${ColourReset}")
		add_custom_target(widget-target-install
			COMMENT "${Red}*** Fatal: RSYNC_TARGET RSYNC_PREFIX environment variables required with 'make widget-target-install'${ColourReset}"
			COMMAND exit -1
		)
	else()
	configure_files_in_dir(${WGT_TEMPLATE_DIR})
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

macro(deb_package_build)
#TODO
endmacro(deb_package_build)

macro(project_package_build)
	if(EXISTS ${RPM_TEMPLATE_DIR})
		rpm_package_build()
	endif()

	if(EXISTS ${WGT_TEMPLATE_DIR})
		wgt_package_build()
	endif()

	if(EXISTS ${DEB_TEMPLATE_DIR})
		deb_package_build()
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
		if(EXISTS "${filename}/CMakeLists.txt")
			add_subdirectory(${filename})
		endif(EXISTS "${filename}/CMakeLists.txt")
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
		 	${DEPENDENCIES_TARGET} ${PROJECT_TARGETS})
	endif()
endmacro()
