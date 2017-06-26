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

include(${PROJECT_APP_TEMPLATES_DIR}/cmake/macros.cmake)
include(${PROJECT_APP_TEMPLATES_DIR}/cmake/variables.cmake)
include(${PROJECT_APP_TEMPLATES_DIR}/cmake/extra_targets.cmake)

# Check GCC minimal version
if (gcc_minimal_version)
		message (STATUS "${Cyan}-- Check gcc_minimal_version (found gcc version ${CMAKE_C_COMPILER_VERSION}) \
		(found g++ version ${CMAKE_CXX_COMPILER_VERSION})${ColourReset}")
	if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version} OR CMAKE_C_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
		message(FATAL_ERROR "${Red}**** FATAL: Require at least gcc-${gcc_minimal_version} please set CMAKE_C[XX]_COMPILER")
	endif()
endif(gcc_minimal_version)

# Check Kernel minimal version
if (kernel_minimal_version)
	if(DEFINED ENV{SDKTARGETSYSROOT})
		file(STRINGS $ENV{SDKTARGETSYSROOT}/usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
	else()
		file(STRINGS /usr/include/linux/version.h LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")
	endif()

	string(REGEX MATCH "[0-9]+" LINUX_VERSION_CODE ${LINUX_VERSION_CODE_LINE})
	math(EXPR a "${LINUX_VERSION_CODE} >> 16")
	math(EXPR b "(${LINUX_VERSION_CODE} >> 8) & 255")
	math(EXPR c "(${LINUX_VERSION_CODE} & 255)")

	set(KERNEL_VERSION "${a}.${b}.${c}")
	message (STATUS "${Cyan}-- Check kernel_minimal_version (found kernel version ${KERNEL_VERSION})${ColourReset}")

	if (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
		message(FATAL_ERROR "${Red}**** FATAL: Require at least ${kernel_minimal_version} please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.")
	endif (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
endif(kernel_minimal_version)

INCLUDE(FindPkgConfig)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)
INCLUDE(GNUInstallDirs)

# Default compilation options
############################################################################
link_libraries(-Wl,--as-needed -Wl,--gc-sections)
add_compile_options(-Wall -Wextra -Wconversion)
add_compile_options(-Wno-unused-parameter) # frankly not using a parameter does it care?
add_compile_options(-Wno-sign-compare -Wno-sign-conversion)
add_compile_options(-Werror=maybe-uninitialized)
add_compile_options(-Werror=implicit-function-declaration)
add_compile_options(-ffunction-sections -fdata-sections)
add_compile_options(-fPIC)
add_compile_options(-g)

set(CMAKE_C_FLAGS_PROFILING   "-g -O2 -pg -Wp,-U_FORTIFY_SOURCE" CACHE STRING "Flags for profiling")
set(CMAKE_C_FLAGS_DEBUG       "-g -O2 -ggdb -Wp,-U_FORTIFY_SOURCE" CACHE STRING "Flags for debugging")
set(CMAKE_C_FLAGS_RELEASE     "-O2" CACHE STRING "Flags for releasing")
set(CMAKE_C_FLAGS_CCOV        "-g -O2 --coverage" CACHE STRING "Flags for coverage test")

set(CMAKE_CXX_FLAGS_PROFILING    "-g -O0 -pg -Wp,-U_FORTIFY_SOURCE")
set(CMAKE_CXX_FLAGS_DEBUG        "-g -O0 -ggdb -Wp,-U_FORTIFY_SOURCE")
set(CMAKE_CXX_FLAGS_RELEASE      "-g -O2")
set(CMAKE_CXX_FLAGS_CCOV "-g -O2 --coverage")

# Env variable overload default
if(DEFINED ENV{INSTALL_PREFIX})
	set (INSTALL_PREFIX $ENV{INSTALL_PREFIX})
else()
	set(INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/Install" CACHE PATH "The path where to install")
endif()
set(CMAKE_INSTALL_PREFIX ${INSTALL_PREFIX} CACHE STRING "Installation Prefix")

# (BUG!!!) as PKG_CONFIG_PATH does not work [should be en env variable]
set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON CACHE BOOLEAN "Flag for using prefix path")

# Loop on required package and add options
foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
	PKG_CHECK_MODULES(${XPREFIX} REQUIRED ${PKG_CONFIG})

	INCLUDE_DIRECTORIES(${${XPREFIX}_INCLUDE_DIRS})
	list (APPEND link_libraries ${${XPREFIX}_LDFLAGS})
	add_compile_options (${${XPREFIX}_CFLAGS})
endforeach(PKG_CONFIG)

# Optional LibEfence Malloc debug library
IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
CHECK_LIBRARY_EXISTS(efence malloc "" HAVE_LIBEFENCE)
IF(HAVE_LIBEFENCE)
	MESSAGE(STATUS "Linking with ElectricFence for debugging purposes...")
	SET(libefence_LIBRARIES "-lefence")
	list (APPEND link_libraries ${libefence_LIBRARIES})
ENDIF(HAVE_LIBEFENCE)
ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)

# set default include directories
INCLUDE_DIRECTORIES(${EXTRA_INCLUDE_DIRS})

# Default Linkflag
if(NOT BINDINGS_LINK_FLAG)
	set(BINDINGS_LINK_FLAG "-Wl,--version-script=${PKG_TEMPLATE_PREFIX}/cmake/export.map")
endif()
