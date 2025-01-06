###########################################################################
# Copyright (C) 2015-2025 IoT.bzh Company
#
# Author: Romain Forlot <romain.forlot@iot.bzh>
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

cmake_minimum_required(VERSION 3.5)

project(CMakeAfbTemplates VERSION 10.0.9)

# compute the default install directory
include(GNUInstallDirs)
get_filename_component(CMAKE_DIR ${CMAKE_ROOT} NAME)
set(INSTALL_DIR ${CMAKE_INSTALL_DATADIR}/${CMAKE_DIR}/Modules)

# install the module
INSTALL(FILES CMakeAfbTemplates.cmake DESTINATION ${INSTALL_DIR})
INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/ DESTINATION ${INSTALL_DIR}/CMakeAfbTemplates)
INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/docs/ DESTINATION ${CMAKE_INSTALL_DOCDIR})

set(PKG_NAME cmake_afb_templates)

configure_file(${PKG_NAME}.pc.in ${PKG_NAME}.pc @ONLY)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/share/pkgconfig)
