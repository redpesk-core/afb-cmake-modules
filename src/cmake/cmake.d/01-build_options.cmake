###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# authors: Fulup Ar Foll <fulup@iot.bzh>
#          Romain Forlot <romain.forlot@iot.bzh>
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

# (BUG!!!) as PKG_CONFIG_PATH does not work [should be en env variable]
set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON CACHE STRING "Flag for using prefix path")

INCLUDE(FindPkgConfig)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)
INCLUDE(GNUInstallDirs)

set(CMP0048 1)

# Loop on required package and add options
foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
	PKG_CHECK_MODULES(${XPREFIX} REQUIRED ${PKG_CONFIG})

	INCLUDE_DIRECTORIES(${${XPREFIX}_INCLUDE_DIRS})
	list(APPEND link_libraries ${${XPREFIX}_LDFLAGS})
	add_compile_options (${${XPREFIX}_CFLAGS})
endforeach(PKG_CONFIG)

# set default include directories
INCLUDE_DIRECTORIES(${EXTRA_INCLUDE_DIRS})

# Default Linkflag
get_filename_component(PKG_TEMPLATE_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." REALPATH CACHE)

if(NOT BINDINGS_LINK_FLAG)
	set(BINDINGS_LINK_FLAG "-Wl,--version-script=${PKG_TEMPLATE_PREFIX}/cmake/export.map")
endif()
if(NOT DEFINED BUILD_TEST_WGT)
	set(BUILD_TEST_WGT FALSE)
endif()

