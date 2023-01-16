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
#     Customise your preferences in "./etc/config.cmake"
#--------------------------------------------------------------------------

# Native packaging name
set(NPKG_PROJECT_NAME agl-${PROJECT_NAME})

# Setup project and app-templates version variables
execute_process(COMMAND git describe --abbrev=0
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE GIT_PROJECT_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Get the git commit hash to append to the version
execute_process(COMMAND git rev-parse --short HEAD
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE COMMIT_HASH
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Detect unstaged or untracked changes
execute_process(COMMAND git status --short
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE DIRTY_FLAG
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Include project configuration
# ------------------------------
if(NOT PROJECT_VERSION AND NOT GIT_PROJECT_VERSION AND NOT VERSION)
	message(FATAL_ERROR "${Red}No version found. Please set a version tag or PROJECT_VERSION cmake variable in your config.cmake. Abort!")
elseif(NOT PROJECT_VERSION AND GIT_PROJECT_VERSION)
	set(PROJECT_VERSION ${GIT_PROJECT_VERSION})
elseif(NOT PROJECT_VERSION AND VERSION)
	set(PROJECT_VERSION ${VERSION})
endif()

if(NOT PROJECT_DESCRIPTION)
    message(WARNING "${Yellow}No description found. Please set a PROJECT_DESCRIPTION cmake variable in your config.cmake.")
    set(PROJECT_DESCRIPTION "-")
endif()

if(NOT PROJECT_URL)
    message(WARNING "${Yellow}No homepage url found. Please set a PROJECT_URL cmake variable in your config.cmake.")
endif()

# Release additionnals informations isn't supported so setting project
# attributes then add the dirty flag if git repo not sync'ed
if(CMAKE_VERSION VERSION_GREATER 3.11)
	if(PROJECT_URL)
		project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES} DESCRIPTION ${PROJECT_DESCRIPTION} HOMEPAGE_URL ${PROJECT_URL})
	else()
		project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES} DESCRIPTION ${PROJECT_DESCRIPTION})
	endif()
else()
	project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES})
endif()
if(NOT ${DIRTY_FLAG})
	set(PROJECT_VERSION "${PROJECT_VERSION}-${COMMIT_HASH}-dirty")
elseif(${COMMIT_VERSION})
	set(PROJECT_VERSION "${PROJECT_VERSION}-${COMMIT_HASH}")
else()
	set(PROJECT_VERSION "${PROJECT_VERSION}")
endif()


set(AFB_REMPORT "1234" CACHE PATH "Default AFB port")

# Check GCC minimal version
if (gcc_minimal_version)
	message ("${Cyan}-- Check gcc_minimal_version (found gcc version ${CMAKE_C_COMPILER_VERSION}) \
	(found g++ version ${CMAKE_CXX_COMPILER_VERSION})${ColourReset}")

	if (("${PROJECT_LANGUAGES}" MATCHES "CXX"
	    AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
	    OR CMAKE_C_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
		message(FATAL_ERROR "${Red}**** FATAL: Require at least gcc-${gcc_minimal_version} please set CMAKE_C[XX]_COMPILER")
	endif()
endif(gcc_minimal_version)

# Project path variables
# ----------------------
set(PKGOUT_DIR package CACHE PATH "Output directory for packages")

# Define a default package directory
if(PKG_PREFIX)
	set(PROJECT_PKG_BUILD_DIR ${PKG_PREFIX}/${PKGOUT_DIR}
	    CACHE PATH "Application contents to be packaged")
else()
	set(PROJECT_PKG_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${PKGOUT_DIR}
	    CACHE PATH "Application contents to be packaged")
endif()
string(REGEX REPLACE "/([^/]*)$" "/\\1-test" PROJECT_PKG_TEST_BUILD_DIR "${PROJECT_PKG_BUILD_DIR}")

# Define a default package install root directory
if(NO_DEDICATED_INSTALL_DIR)
	set(PKG_INSTALL_SUBDIR        ""      CACHE STRING "subdir pkg name" FORCE)
	set(PKG_TEST_INSTALL_SUBDIR   "test"  CACHE STRING "subdir test's pkg name" FORCE)
else()
	set(PKG_INSTALL_SUBDIR        ${PROJECT_NAME}                       CACHE STRING "subdir pkg name")
	set(PKG_TEST_INSTALL_SUBDIR   ${PKG_INSTALL_SUBDIR}-test            CACHE STRING "subdir test's pkg name")
endif()
set(AFM_APP_DIR               ${CMAKE_INSTALL_PREFIX}/redpesk               CACHE PATH   "Root dir for afm app install")
set(PKG_INSTALL_ROOT_DIR      ${AFM_APP_DIR}                                CACHE PATH   "Root dir for pkg install")
set(PKG_INSTALL_DIR           ${PKG_INSTALL_ROOT_DIR}/${PKG_INSTALL_SUBDIR} CACHE PATH   "pkg install path")
set(PKG_TEST_INSTALL_ROOT_DIR ${PKG_INSTALL_ROOT_DIR}                       CACHE PATH   "Root dir for test's pkg install")
set(PKG_TEST_INSTALL_DIR      ${PKG_TEST_INSTALL_ROOT_DIR}/${PKG_TEST_INSTALL_SUBDIR} CACHE PATH   "test's pkg install path")

set(PROJECT_APP_TEMPLATES_DIR "${CMAKE_CURRENT_LIST_DIR}/../..")

set(TEMPLATE_DIR "${PROJECT_APP_TEMPLATES_DIR}/template.d"
    CACHE PATH "Subpath to a directory where are stored needed files to launch on remote target to debuging purposes")

set(PROJECT_PKG_ENTRY_POINT ${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/packaging
    CACHE PATH "Where package build files, like rpm.spec file or config.xml, are write.")

set(WIDGET_ICON "${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_CONF_DIR}/wgt/${PROJECT_ICON}"
    CACHE PATH "Path to the widget icon")

if(NOT WIDGET_CONFIG_TEMPLATE)
	set(WIDGET_CONFIG_TEMPLATE ${TEMPLATE_DIR}/config.xml.in
		CACHE PATH "Path to widget config file template (config.xml.in)")
endif()

# Path to autobuild template
set(PROJECT_AGL_AUTOBUILD_DIR ${CMAKE_SOURCE_DIR}/autobuild/agl
    CACHE PATH "Subpath to a directory where are stored autobuild script")
set(PROJECT_LINUX_AUTOBUILD_DIR ${CMAKE_SOURCE_DIR}/autobuild/linux
    CACHE PATH "Subpath to a directory where are stored autobuild script")

# Path to test template
set(PROJECT_TEST_DIR ${CMAKE_SOURCE_DIR}/test
    CACHE PATH "Subpath to a directory where are stored test tree")

if(OSRELEASE MATCHES "debian" AND NOT DEFINED ENV{SDKTARGETSYSROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
	# build deb spec file from template
	set(PACKAGING_DEB_OUTPUT_DSC       ${PROJECT_PKG_ENTRY_POINT}/${NPKG_PROJECT_NAME}.dsc)
	set(PACKAGING_DEB_OUTPUT_INSTALL   ${PROJECT_PKG_ENTRY_POINT}/debian.${NPKG_PROJECT_NAME}.install)
	set(PACKAGING_DEB_OUTPUT_CHANGELOG ${PROJECT_PKG_ENTRY_POINT}/debian.changelog)
	set(PACKAGING_DEB_OUTPUT_COMPAT    ${PROJECT_PKG_ENTRY_POINT}/debian.compat)
	set(PACKAGING_DEB_OUTPUT_CONTROL   ${PROJECT_PKG_ENTRY_POINT}/debian.control)
	set(PACKAGING_DEB_OUTPUT_RULES     ${PROJECT_PKG_ENTRY_POINT}/debian.rules)
endif()

# Break After Binding are loaded but before they get initialised
set(GDB_INITIAL_BREAK "personality" CACHE STRING "Initial Break Point for GDB remote")

# Default GNU directories path variables
set(BINDIR bin CACHE PATH "User executables")
set(ETCDIR etc CACHE PATH "Read only system configuration data")
set(LIBDIR lib CACHE PATH "System library directory")
set(HTTPDIR htdocs CACHE PATH "HTML5 data directory")
set(DATADIR var CACHE PATH "External data resources files")

# Normally CMake uses the build tree for the RPATH when building executables
# etc on systems that use RPATH. When the software is installed the executables
# etc are relinked by CMake to have the install RPATH. If this variable is set
# to true then the software is always built with the install path for the RPATH
# and does not need to be relinked when installed.
# Rpath could be set and controlled by target property INSTALL_RPATH
set(CMAKE_BUILD_WITH_INSTALL_RPATH true)

