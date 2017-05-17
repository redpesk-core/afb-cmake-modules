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
set(PROJECT_NAME native-example)
set(VERSION "0.0")
set(PROJECT_PRETTY_NAME "Native Example")
set(PROJECT_DESCRIPTION "Native AGL application example")
set(PROJECT_URL "https://gerrit.automotivelinux.org/gerrit/apps/app-templates")
set(PROJECT_AUTHOR "Last Name, First Name")
set(PROJECT_AUTHOR_MAIL "example.man@bigouden.bzh")
set(PROJECT_ICON "icon.png")

# Compilation Mode (DEBUG, RELEASE)
# ----------------------------------
set(CMAKE_BUILD_TYPE "DEBUG")

# Compiler selection if needed. Impose a minimal version.
# -----------------------------------------------
set (gcc_minimal_version 4.9)

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
set(CLOSING_MESSAGE "Test launching application with : afb-daemon --rootdir=\$\$(pwd)/package --ldpaths=\$\$(pwd)/package/lib --port=1234 --roothttp=\$\$(pwd)/package/htdocs --tracereq=common --token=\"1\" --verbose")
set(WIDGET_MESSAGE "Install widget file using in the target : afm-util install ${PROJECT_NAME}.wgt")

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
# set(BINDINGS_INSTALL_PREFIX PrefixPath )

# Optional force widget prefix generation
# ------------------------------------------------
# set(WIDGET_PREFIX DestinationPath)

# Optional Widget entry point file.
# ---------------------------------------------------------
 # This is the file that will be executed, loaded,...
# at launch time by the application framework

# set(WIDGET_ENTRY_POINT EntryPoint_Path)

# Optional Widget Mimetype specification
# --------------------------------------------------
# Choose between :
# - application/x-executable
# - application/vnd.agl.url
# - application/vnd.agl.service
# - application/vnd.agl.native
# - text/vnd.qt.qml
# - text/html
# - application/vnd.agl.qml
# - application/vnd.agl.qml.hybrid
# - application/vnd.agl.html.hybrid
#
# set(WIDGET_TYPE MimeType)

# Optional force binding Linking flag
# ------------------------------------
# set(BINDINGS_LINK_FLAG LinkOptions )

