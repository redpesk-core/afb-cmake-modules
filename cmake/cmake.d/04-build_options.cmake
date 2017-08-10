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

# Check GCC minimal version
if (gcc_minimal_version)
		message (STATUS "${Cyan}-- Check gcc_minimal_version (found gcc version ${CMAKE_C_COMPILER_VERSION}) \
		(found g++ version ${CMAKE_CXX_COMPILER_VERSION})${ColourReset}")
	if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version} OR CMAKE_C_COMPILER_VERSION VERSION_LESS ${gcc_minimal_version})
		message(FATAL_ERROR "${Red}**** FATAL: Require at least gcc-${gcc_minimal_version} please set CMAKE_C[XX]_COMPILER")
	endif()
endif(gcc_minimal_version)

# Check Kernel mandatory version, will fail the configuration if required version not matched.
if (kernel_mandatory_version)
	message (STATUS "${Cyan}-- Check kernel_mandatory_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
	if (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
		message(FATAL_ERROR "${Red}**** FATAL: Require at least ${kernel_mandatory_version} please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.")
	endif (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
endif(kernel_mandatory_version)

# Check Kernel minimal version just print a Warning about missing features
# and set a definition to be used as preprocessor condition in code to disable
# incompatibles features.
if (kernel_minimal_version)
	message (STATUS "${Cyan}-- Check kernel_minimal_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
	if (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
		message(WARNING "${Yellow}**** Warning: Some feature(s) require at least ${kernel_minimal_version}. Please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.${ColourReset}")
	else (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
		add_definitions(-DKERNEL_MINIMAL_VERSION_OK)
	endif (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
endif(kernel_minimal_version)

INCLUDE(FindPkgConfig)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)
INCLUDE(GNUInstallDirs)

# Default compilation options
############################################################################
link_libraries(-Wl,--as-needed -Wl,--gc-sections)
set(COMPILE_OPTIONS "-Wall" "-Wextra" "-Wconversion" "-Wno-unused-parameter" "-Wno-sign-compare" "-Wno-sign-conversion" "-Werror=maybe-uninitialized" "-Werror=implicit-function-declaration" "-ffunction-sections" "-fdata-sections" "-fPIC" CACHE STRING "Compilation flags")
foreach(option ${COMPILE_OPTIONS})
	add_compile_options($<$<CONFIG:PROFILING>:${option}>)
endforeach()

# Compilation OPTIONS depending on language
#########################################

foreach(option ${COMPILE_OPTIONS})
	add_compile_options(${option})
endforeach()
foreach(option ${C_COMPILE_OPTIONS})
	add_compile_options($<$<COMPILE_LANGUAGE:C>:${option}>)
endforeach()
foreach(option ${CXX_COMPILE_OPTIONS})
	add_compile_options($<$<COMPILE_LANGUAGE:CXX>:${option}>)
endforeach()

# Compilation option depending on CMAKE_BUILD_TYPE
##################################################
set(PROFILING_COMPILE_OPTIONS "-g" "-O0" "-pg" "-Wp,-U_FORTIFY_SOURCE" CACHE STRING "Compilation flags for PROFILING build type.")
set(DEBUG_COMPILE_OPTIONS "-g" "-ggdb" "-Wp,-U_FORTIFY_SOURCE" CACHE STRING "Compilation flags for DEBUG build type.")
set(CCOV_COMPILE_OPTIONS "-g" "-O2" "--coverage" CACHE STRING "Compilation flags for CCOV build type.")
set(RELEASE_COMPILE_OPTIONS "-g" "-O2" CACHE STRING "Compilation flags for RELEASE build type.")
foreach(option ${PROFILING_COMPILE_OPTIONS})
	add_compile_options($<$<CONFIG:PROFILING>:${option}>)
endforeach()
foreach(option ${DEBUG_COMPILE_OPTIONS})
	add_compile_options($<$<CONFIG:PROFILING>:${option}>)
endforeach()
foreach(option ${CCOV_COMPILE_OPTIONS})
	add_compile_options($<$<CONFIG:PROFILING>:${option}>)
endforeach()
foreach(option ${RELEASE_COMPILE_OPTIONS})
	add_compile_options($<$<CONFIG:PROFILING>:${option}>)
endforeach()

# Env variable overload default
if(DEFINED ENV{INSTALL_PREFIX})
	set(INSTALL_PREFIX $ENV{INSTALL_PREFIX} CACHE PATH "The path where to install")
else()
	set(INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/Install" CACHE PATH "The path where to install")
endif()
set(CMAKE_INSTALL_PREFIX ${INSTALL_PREFIX} CACHE STRING "Installation Prefix")

# Loop on required package and add options
foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
	PKG_CHECK_MODULES(${XPREFIX} REQUIRED ${PKG_CONFIG})

	INCLUDE_DIRECTORIES(${${XPREFIX}_INCLUDE_DIRS})
	list(APPEND link_libraries ${${XPREFIX}_LDFLAGS})
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
