###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Fulup Ar Foll <fulup@iot.bzh>
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

# Project Info
# ------------------
set(NAME service-example)
set(VERSION "0.0")
set(PROJECT_PRETTY_NAME "Service binding Example")
set(PROJECT_DESCRIPTION "service binding AGL application example")
set(PROJECT_URL "https://gerrit.automotivelinux.org/gerrit/apps/app-templates")
set(PROJECT_ICON "icon.png")

# Compilation Mode (DEBUG, RELEASE)
# ----------------------------------
set(CMAKE_BUILD_TYPE "DEBUG")

# Compiler selection if needed. Overload the detected compiler.
# -----------------------------------------------
#set(CMAKE_C_COMPILER "gcc")
#set(CMAKE_CXX_COMPILER "g++")

# PKG_CONFIG required packages
# -----------------------------
set (PKG_REQUIRED_LIST 
	json-c
	afb-daemon
)

# Static constante definition
# -----------------------------
add_compile_options()

# LANG Specific compile flags set for all build types
set(CMAKE_C_FLAGS "")
set(CMAKE_CXX_FLAGS "")

# Print a helper message when every thing is finished
# ----------------------------------------------------
#set(CLOSING_MESSAGE "")


# (BUG!!!) as PKG_CONFIG_PATH does not work [should be an env variable]
# ---------------------------------------------------------------------
set(CMAKE_INSTALL_PREFIX ${HOME}/opt)
set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/lib64/pkgconfig ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
set(LD_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib64 ${CMAKE_INSTALL_PREFIX}/lib)

# Optional dependencies order
# ---------------------------
#set(EXTRA_DEPENDENCIES_ORDER)

# Optional Extra global include path
# -----------------------------------
#set(EXTRA_INCLUDE_DIRS)

# Optional extra libraries
# -------------------------
#set(EXTRA_LINK_LIBRARIES)

# Optional force binding installation
# ------------------------------------
set(BINDINGS_INSTALL_PREFIX /opt )

# Optional force widget prefix generation
# ---------------------------------------
# set(WIDGET_PREFIX DestinationPath)

# Optional force binding Linking flag
# ------------------------------------
# set(BINDINGS_LINK_FLAG LinkOptions )
