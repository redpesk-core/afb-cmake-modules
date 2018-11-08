###########################################################################
# Copyright 2015 - 2018 IoT.bzh
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

# Include ExternalProject CMake module by default
include(ExternalProject)

if(DEFINED ENV{SDKTARGETSYSROOT})
file(STRINGS $ENV{SDKTARGETSYSROOT}/usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT $ENV{SDKTARGETSYSROOT})
elseif(DEFINED ENV{PKG_CONFIG_SYSROOT_DIR})
file(STRINGS $ENV{PKG_CONFIG_SYSROOT_DIR}/usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT $ENV{PKG_CONFIG_SYSROOT_DIR})
else()
file(STRINGS /usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
set(BUILD_ENV_SYSROOT "")
endif()

# Get the os type
# Used to package .deb
set(OS_RELEASE_PATH "${BUILD_ENV_SYSROOT}/etc/os-release")
if(EXISTS ${OS_RELEASE_PATH})
	execute_process(COMMAND bash "-c" "grep -E '^ID(_LIKE)?=' ${OS_RELEASE_PATH} | tail -n 1"
		OUTPUT_VARIABLE TMP_OSRELEASE
	)

	if (NOT TMP_OSRELEASE STREQUAL "")
		string(REGEX REPLACE ".*=\"?([0-9a-z\._ -]*)\"?\n" "\\1" OSDETECTED ${TMP_OSRELEASE})
		string(REPLACE " " ";" OSRELEASE ${OSDETECTED})
	else()
		set(OSRELEASE "NOT COMPATIBLE !")
	endif()
elseif("${BUILD_ENV_SYSROOT}" STREQUAL "$ENV{PKG_CONFIG_SYSROOT_DIR}")
	set(OSRELEASE "yocto-build")
else()
	set(OSRELEASE "NOT COMPATIBLE ! Missing ${OS_RELEASE_PATH} file.")
endif()
message("Distribution detected (separated by ';' choose one of them) ${OSRELEASE}")

# Include CMake modules core files
file(GLOB project_cmakefiles ${CMAKE_CURRENT_LIST_DIR}/cmake.d/[0-9][0-9]-*.cmake)
list(SORT project_cmakefiles)

# Include optionnal user defined OS relative CMake files
foreach(OS IN LISTS OSRELEASE)
	list(APPEND PATTERN "${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/cmake/[0-9][0-9]-${OS}*.cmake"
			    "${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/cmake.d/[0-9][0-9]-${OS}*.cmake")
endforeach()
list(APPEND PATTERN "${PROJECT_CMAKE_CONF_DIR}/cmake/[0-9][0-9]-common*.cmake"
		    "${PROJECT_CMAKE_CONF_DIR}/cmake.d/[0-9][0-9]-common*.cmake")

file(GLOB distro_cmakefiles ${PATTERN})

if(NOT distro_cmakefiles)
	file(GLOB distro_cmakefiles ${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/cmake/[0-9][0-9]-default*.cmake
				    ${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/cmake.d/[0-9][0-9]-default*.cmake)
endif()

list(SORT distro_cmakefiles)

file(GLOB home_cmakefiles $ENV{HOME}/.config/app-templates/cmake.d/[0-9][0-9]-common*.cmake
			  $ENV{HOME}/.config/app-templates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake
			  $ENV{HOME}/.config/cmake-apps-module/cmake.d/[0-9][0-9]-common*.cmake
			  $ENV{HOME}/.config/cmake-apps-module/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake
			  $ENV{HOME}/.config/CMakeAfbTemplates/cmake.d/[0-9][0-9]-common*.cmake
			  $ENV{HOME}/.config/CMakeAfbTemplates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake)
list(SORT home_cmakefiles)

file(GLOB system_cmakefiles /etc/app-templates/cmake.d/[0-9][0-9]-common*.cmake
			    /etc/app-templates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake
			    /etc/cmake-apps-module/cmake.d/[0-9][0-9]-common*.cmake
			    /etc/cmake-apps-module/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake
			    /etc/CMakeAfbTemplates/cmake.d/[0-9][0-9]-common*.cmake
			    /etc/CMakeAfbTemplates/cmake.d/[0-9][0-9]-${PROJECT_NAME}*.cmake)
list(SORT system_cmakefiles)

foreach(file ${system_cmakefiles} ${home_cmakefiles} ${distro_cmakefiles} ${project_cmakefiles})
	message("Include: ${file}")
	include(${file})
endforeach()

set_install_prefix()
prevent_in_source_build()

if(DEFINED PROJECT_SRC_DIR_PATTERN)
	project_subdirs_add(${PROJECT_SRC_DIR_PATTERN})
else()
	project_subdirs_add()
endif(DEFINED PROJECT_SRC_DIR_PATTERN)

configure_files_in_dir(${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/template.d)
configure_files_in_dir($ENV{HOME}/.config/app-templates/scripts)
configure_files_in_dir(/etc/app-templates/scripts)

project_targets_populate()
remote_targets_populate()
project_package_build()
project_closing_msg()
