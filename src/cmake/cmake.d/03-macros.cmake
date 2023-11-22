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

# Generic useful macro
# -----------------------
macro(PROJECT_TARGET_ADD TARGET_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_TARGETS ${TARGET_NAME})
	set(TARGET_NAME ${TARGET_NAME})
endmacro(PROJECT_TARGET_ADD)

macro(PROJECT_PKGDEP_ADD PKG_NAME)
	set_property(GLOBAL APPEND PROPERTY PROJECT_PKG_DEPS ${PKG_NAME})
endmacro(PROJECT_PKGDEP_ADD)

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

# Common command to call inside project_targets_populate macro
macro(generate_one_populate_target OUTPUTFILES PKG_DESTDIR)
	add_custom_command(
		OUTPUT ${PKG_DESTDIR}/${OUTPUTFILES}
		DEPENDS ${BD}/${OUTPUTFILES}
		COMMAND mkdir -p ${PKG_DESTDIR}
		COMMAND touch ${PKG_DESTDIR}
		COMMAND cp -dr ${BD}/${OUTPUTFILES}/* ${PKG_DESTDIR} 2> /dev/null || cp -d ${BD}/${OUTPUTFILES} ${PKG_DESTDIR}
	)

	add_custom_target(${POPULE_PACKAGE_TARGET} DEPENDS ${PKG_DESTDIR}/${OUTPUTFILES})
	add_dependencies(populate ${POPULE_PACKAGE_TARGET})
	add_dependencies(${POPULE_PACKAGE_TARGET} ${TARGET})
endmacro()

macro(make_prepare_package)
	if(NOT PACKAGE_BINDIR)
		# Default Widget default directory
		set(PACKAGE_BINDIR  ${PROJECT_PKG_BUILD_DIR}/${BINDIR})
		set(PACKAGE_ETCDIR  ${PROJECT_PKG_BUILD_DIR}/${ETCDIR})
		set(PACKAGE_LIBDIR  ${PROJECT_PKG_BUILD_DIR}/${LIBDIR})
		set(PACKAGE_HTTPDIR ${PROJECT_PKG_BUILD_DIR}/${HTTPDIR})
		set(PACKAGE_DATADIR ${PROJECT_PKG_BUILD_DIR}/${DATADIR})

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

		add_dependencies(populate prepare_package)
	endif()
endmacro(make_prepare_package)

macro(make_prepare_package_test)
	if(NOT PACKAGE_TEST_BINDIR)
		# Default test Widget default directory
		set(PACKAGE_TEST_BINDIR  ${PROJECT_PKG_TEST_BUILD_DIR}/${BINDIR})
		set(PACKAGE_TEST_ETCDIR  ${PROJECT_PKG_TEST_BUILD_DIR}/${ETCDIR})
		set(PACKAGE_TEST_LIBDIR  ${PROJECT_PKG_TEST_BUILD_DIR}/${LIBDIR})
		set(PACKAGE_TEST_HTTPDIR ${PROJECT_PKG_TEST_BUILD_DIR}/${HTTPDIR})
		set(PACKAGE_TEST_DATADIR ${PROJECT_PKG_TEST_BUILD_DIR}/${DATADIR})

		add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}
				   COMMAND mkdir -p ${PROJECT_PKG_TEST_BUILD_DIR})
		add_custom_command(OUTPUT ${PACKAGE_TEST_BINDIR}
				   COMMAND mkdir -p ${PACKAGE_TEST_BINDIR}
				   DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR})
		add_custom_command(OUTPUT ${PACKAGE_TEST_ETCDIR}
				   COMMAND mkdir -p ${PACKAGE_TEST_ETCDIR}
				   DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR})
		add_custom_command(OUTPUT ${PACKAGE_TEST_LIBDIR}
				   COMMAND mkdir -p ${PACKAGE_TEST_LIBDIR}
				   DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR})
		add_custom_command(OUTPUT ${PACKAGE_TEST_HTTPDIR}
				   COMMAND mkdir -p ${PACKAGE_TEST_HTTPDIR}
				   DEPENDS ${PROJECT_PKG_TEST_TEST_DIR})
		add_custom_command(OUTPUT ${PACKAGE_TEST_DATADIR}
				   COMMAND mkdir -p ${PACKAGE_TEST_DATADIR}
				   DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR})

		add_custom_target(prepare_package_test
					DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR}
						${PACKAGE_TEST_BINDIR}
						${PACKAGE_TEST_ETCDIR}
						${PACKAGE_TEST_LIBDIR}
						${PACKAGE_TEST_HTTPDIR}
						${PACKAGE_TEST_DATADIR})

		add_dependencies(populate prepare_package_test)
	endif()
endmacro(make_prepare_package_test)

# app entry point
macro(set_app_entry_point)
	if(NOT WIDGET_ENTRY_POINT)
		set(WIDGET_ENTRY_POINT lib)
	endif()
endmacro(set_app_entry_point)


# app name
macro(set_app_name)
	if(NOT ${CMAKE_BUILD_TYPE} STREQUAL "RELEASE")
		string(TOLOWER "${PROJECT_NAME}-${CMAKE_BUILD_TYPE}" WGT_NAME)
	else()
		string(TOLOWER "${PROJECT_NAME}" WGT_NAME)
	endif()
endmacro(set_app_name)


macro(make_app_files_target)
if(NOT make_app_files_target_done)
set(make_app_files_target_done YES)
	# checks
	if(MANIFEST_YAML_TEMPLATE AND NOT EXISTS ${MANIFEST_YAML_TEMPLATE})
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build application.
You need a manifest.yml template: please set MANIFEST_YAML_TEMPLATE correctly.${ColourReset}")
	elseif(WIDGET_CONFIG_TEMPLATE AND NOT EXISTS ${WIDGET_CONFIG_TEMPLATE})
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build widget file.
You need a config.xml template: please specify WIDGET_CONFIG_TEMPLATE correctly.${ColourReset}")
	endif()

	set_app_name()
	set_app_entry_point()

	# the targets
	set(widget_files_items)

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
	if(MANIFEST_YAML_TEMPLATE)
		add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/.rpconfig/manifest.yml
			COMMAND mkdir ${PROJECT_PKG_BUILD_DIR}/.rpconfig
			COMMAND ${CMAKE_COMMAND}
				-DINFILE=${MANIFEST_YAML_TEMPLATE}
				-DOUTFILE=${PROJECT_PKG_BUILD_DIR}/.rpconfig/manifest.yml
				-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
				-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
		)
		list(APPEND widget_files_items ${PROJECT_PKG_BUILD_DIR}/.rpconfig/manifest.yml)
	else()
		add_custom_command(OUTPUT ${PROJECT_PKG_BUILD_DIR}/config.xml
			COMMAND ${CMAKE_COMMAND} -DINFILE=${WIDGET_CONFIG_TEMPLATE} -DOUTFILE=${PROJECT_PKG_BUILD_DIR}/config.xml
				-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
				-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
		)
		list(APPEND widget_files_items ${PROJECT_PKG_BUILD_DIR}/config.xml)
	endif()

	make_prepare_package()
	add_custom_target(widget_files DEPENDS prepare_package ${PROJECT_TARGETS} ${widget_files_items})
endif()
endmacro(make_app_files_target)


macro(make_app_test_files_target)
if(NOT make_app_test_files_target_done)
set(make_app_test_files_target_done YES)
	# default test template
	if(TEST_MANIFEST_YAML_TEMPLATE AND NOT EXISTS ${TEST_MANIFEST_YAML_TEMPLATE})
		MESSAGE(FATAL_ERROR "${Red}WARNING ! Missing mandatory files to build test.
You need a manifest.yml template: please set TEST_MANIFEST_YAML_TEMPLATE correctly.${ColourReset}")
	elseif(NOT EXISTS ${TEST_WIDGET_CONFIG_TEMPLATE})
		MESSAGE("${BoldBlue}-- Notice: Using default test widget configuration's file.
-- If you want to use a customized test-config.xml template then specify TEST_WIDGET_CONFIG_TEMPLATE in your config.cmake file.${ColourReset}")

		set(TEST_WIDGET_CONFIG_TEMPLATE "${PROJECT_APP_TEMPLATES_DIR}/test-wgt/test-config.xml.in"
		    CACHE PATH "Path to the test widget config file template (test-config.xml.in)")
	endif()

	# the targets
	set(test_widget_files_items)

	# populate icon
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}/${PROJECT_ICON}
		COMMAND cp -d ${ICON_PATH} ${PROJECT_PKG_TEST_BUILD_DIR}/${PROJECT_ICON}
		DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR}
	)
	list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_BUILD_DIR}/${PROJECT_ICON})

	# instanciate config.xml
	if(TEST_MANIFEST_YAML_TEMPLATE)
		add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}/.rpconfig/manifest.yml
			COMMAND mkdir ${PROJECT_PKG_TEST_BUILD_DIR}/.rpconfig
			COMMAND ${CMAKE_COMMAND}
				-DINFILE=${TEST_MANIFEST_YAML_TEMPLATE}
				-DOUTFILE=${PROJECT_PKG_TEST_BUILD_DIR}/.rpconfig/manifest.yml
				-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
				-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
		)
		list(APPEND widget_files_items ${PROJECT_PKG_TEST_BUILD_DIR}/.rpconfig/manifest.yml)
	else()
		add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}/config.xml
			COMMAND ${CMAKE_COMMAND} -DINFILE=${TEST_WIDGET_CONFIG_TEMPLATE} -DOUTFILE=${PROJECT_PKG_TEST_BUILD_DIR}/config.xml
				-DPROJECT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
				-P ${PROJECT_APP_TEMPLATES_DIR}/cmake/configure_file.cmake
		)
		list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_BUILD_DIR}/config.xml)
	endif()

	# add test launcher
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}/bin
		COMMAND mkdir -p ${PROJECT_PKG_TEST_BUILD_DIR}/bin
	)
	add_custom_command(OUTPUT ${PROJECT_PKG_TEST_BUILD_DIR}/bin/launcher
		COMMAND cp -d ${PROJECT_APP_TEMPLATES_DIR}/test-wgt/launcher.sh.in ${PROJECT_PKG_TEST_BUILD_DIR}/bin/launcher
		DEPENDS ${PROJECT_PKG_TEST_BUILD_DIR}/bin
	)
	list(APPEND test_widget_files_items ${PROJECT_PKG_TEST_BUILD_DIR}/bin/launcher)

	make_prepare_package_test()
	add_custom_target(test_widget_files DEPENDS prepare_package_test ${PROJECT_TARGETS} ${test_widget_files_items})
endif()
endmacro(make_app_test_files_target)

# Pre-packaging
macro(project_targets_populate)

	add_custom_target(populate)
	make_prepare_package()
	make_prepare_package_test()
	make_app_files_target()
	make_app_test_files_target()

	set(HASPKG NO)
	set(HASPKGTST NO)
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
		if(NOT SUBTYPE MATCHES NOTFOUND)
			get_target_property(P ${TARGET} PREFIX)
			get_target_property(S ${TARGET} SUFFIX)
			get_target_property(BD ${TARGET} BINARY_DIR)
			get_target_property(SD ${TARGET} SOURCE_DIR)
			get_target_property(OUT ${TARGET} OUTPUT_NAME)
			get_target_property(IMPPATH ${TARGET} IMPORTED_LOCATION)

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

			if(${SUBTYPE} STREQUAL "LIBRARY")
				set(HASPKG YES)
				unset(BD)
				generate_one_populate_target(${IMPPATH} ${PACKAGE_LIBDIR})
			elseif(${SUBTYPE} STREQUAL "PLUGIN")
				set(HASPKG YES)
				if(NOT S)
					set(S ".ctlso")
				endif()
				generate_one_populate_target(${P}${OUT}${S} "${PACKAGE_LIBDIR}/plugins")
			elseif(${SUBTYPE} STREQUAL "BINDING")
				set(HASPKG YES)
				if(NOT S)
					set(S ".so")
				endif()
				list(APPEND BINDINGS_LIST "${P}${OUT}${S}")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_PROPERTY(TARGET ${TARGET} APPEND PROPERTY LINK_FLAGS ${BINDINGS_LINK_FLAG})
			elseif(${SUBTYPE} STREQUAL "BINDINGV2")
				set(HASPKG YES)
				if(NOT S)
					set(S ".so")
				endif()
				afb_genskel("-2")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_PROPERTY(TARGET ${TARGET} APPEND PROPERTY LINK_FLAGS ${BINDINGS_LINK_FLAG})
			elseif(${SUBTYPE} STREQUAL "BINDINGV3")
				set(HASPKG YES)
				if(NOT S)
					set(S ".so")
				endif()
				afb_genskel("-3")
				generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_LIBDIR})
				SET_PROPERTY(TARGET ${TARGET} APPEND PROPERTY LINK_FLAGS ${BINDINGS_LINK_FLAG})
			elseif(${SUBTYPE} STREQUAL "EXECUTABLE")
				set(HASPKG YES)
				if(NOT S)
					set(S "")
				endif()
				if(NOT OUT AND IMPPATH)
					unset(BD)
					generate_one_populate_target(${IMPPATH} ${PACKAGE_BINDIR})
				else()
					generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_BINDIR})
				endif()
			elseif(${SUBTYPE} STREQUAL "HTDOCS")
				set(HASPKG YES)
				generate_one_populate_target(${P}${OUT} ${PACKAGE_HTTPDIR})
			elseif(${SUBTYPE} STREQUAL "DATA" )
				set(HASPKG YES)
				generate_one_populate_target(${TARGET} ${PACKAGE_DATADIR})
			elseif(${SUBTYPE} STREQUAL "BINDING-CONFIG" )
				set(HASPKG YES)
				generate_one_populate_target(${TARGET} ${PACKAGE_ETCDIR})
			#
			elseif(${SUBTYPE} STREQUAL "TEST-LIBRARY")
				set(HASPKGTST YES)
				unset(BD)
				generate_one_populate_target(${IMPPATH} ${PACKAGE_TEST_LIBDIR})
			elseif(${SUBTYPE} STREQUAL "TEST-PLUGIN")
				set(HASPKGTST YES)
				if(NOT S)
					set(S ".ctlso")
				endif()
				generate_one_populate_target(${P}${OUT}${S} "${PACKAGE_TEST_LIBDIR}/plugins")
			elseif(${SUBTYPE} STREQUAL "TEST-EXECUTABLE")
				set(HASPKGTST YES)
				if(NOT S)
					set(S "")
				endif()
				if(NOT OUT AND IMPPATH)
					unset(BD)
					generate_one_populate_target(${IMPPATH} ${PACKAGE_TEST_BINDIR})
				else()
					generate_one_populate_target(${P}${OUT}${S} ${PACKAGE_TEST_BINDIR})
				endif()
			elseif(${SUBTYPE} STREQUAL "TEST-HTDOCS")
				set(HASPKGTST YES)
				generate_one_populate_target(${P}${OUT} ${PACKAGE_HTTPDIR})
			elseif(${SUBTYPE} STREQUAL "TEST-DATA")
				set(HASPKGTST YES)
				generate_one_populate_target(${TARGET} ${PACKAGE_TEST_DATADIR})
			elseif(${SUBTYPE} STREQUAL "TEST-CONFIG")
				set(HASPKGTST YES)
				generate_one_populate_target(${TARGET} ${PACKAGE_TEST_ETCDIR})
			endif()
		elseif("${CMAKE_BUILD_TYPE}" MATCHES "[Dd][Ee][Bb][Uu][Gg]")
			MESSAGE("${BoldBlue}.. Notice: ${TARGET} ignored when packaging.${ColourReset}")
		endif()
	endforeach()

	# Dirty trick to define a default INSTALL command for app-templates handled
	# targets
	INSTALL(CODE "execute_process(COMMAND make populate)")
	if(HASPKG)
		add_dependencies(populate widget_files)
		INSTALL(DIRECTORY ${PROJECT_PKG_BUILD_DIR}/
			DESTINATION ${PKG_INSTALL_DIR}
			USE_SOURCE_PERMISSIONS
		)
	endif(HASPKG)
	if(HASPKGTST)
		add_dependencies(populate test_widget_files)
		INSTALL(DIRECTORY ${PROJECT_PKG_TEST_BUILD_DIR}/
			DESTINATION ${PKG_TEST_INSTALL_DIR}
			USE_SOURCE_PERMISSIONS
		)
	endif(HASPKGTST)

endmacro(project_targets_populate)



macro(make_widget_target TARGET WIDGET DIR DEPEND)
	# search widget forge
	if(NOT packCMD)
		find_program(wgtpkgCMD "wgtpkg-pack")
		if(wgtpkgCMD)
			set(packCMD "WGTPKG")
		else()
			find_program(zipCMD "zip")
			if(zipCMD)
				set(packCMD "ZIP")
			else()
				set(packCMD "NONE")
			endif()
		endif()
	endif()
	# create package
	if(packCMD STREQUAL "WGTPKG")
		add_custom_target(${TARGET}
			COMMAND ${wgtpkgCMD} "-f" "-o" "${WIDGET}" ${DIR}
			DEPENDS ${DEPEND}
			BYPRODUCTS "${WIDGET}")
	elseif(packCMD STREQUAL "ZIP")
		add_custom_target(${TARGET}
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --yellow "Warning: Widget will be built using Zip, NOT using the Application Framework widget pack command."
			COMMAND cd ${PROJECT_PKG_BUILD_DIR} && ${zipCMD} -r "../${WGT_NAME}.wgt" "*"
			DEPENDS ${DEPEND}
			BYPRODUCTS "${WIDGET}")
	else()
		add_custom_target(${TARGET}
			COMMAND ${CMAKE_COMMAND} -E cmake_echo_color  --red "Error: No utility found to build a widget. Either install wgtpkg-pack from App Framework or zip command"
			COMMAND false
			DEPENDS ${DEPEND})
	endif()
endmacro(make_widget_target)

macro(wgt_package_build)
	# check if widget is required
	if(WIDGET_TYPE)

		make_app_files_target()
		make_app_test_files_target()

		make_widget_target(widget ${WGT_NAME}.wgt ${PROJECT_PKG_BUILD_DIR} widget_files populate)
		make_widget_target(test_widget ${WGT_NAME}-test.wgt ${PROJECT_PKG_TEST_BUILD_DIR} test_widget_files populate)

		if(${BUILD_TEST_WGT})
			add_dependencies(widget test_widget)
		endif()


		if(NOT RSYNC_TARGET)
			message ("${Yellow}.. Warning: RSYNC_TARGET not defined 'make widget-target-install' not instanciated${ColourReset}")
			add_custom_target(widget-target-install
				COMMENT "${Red}*** Fatal: RSYNC_TARGET RSYNC_PREFIX environment variables required with 'make widget-target-install'${ColourReset}"
				COMMAND exit 1
			)
		else()
			configure_files_in_dir(${TEMPLATE_DIR})
			add_custom_target(widget-target-install
				DEPENDS widget
				COMMAND chmod +x ${CMAKE_CURRENT_BINARY_DIR}/target/install-wgt-on-${RSYNC_TARGET}.sh
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/target/install-wgt-on-${RSYNC_TARGET}.sh
			)
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
