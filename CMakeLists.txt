###########################################################################
# Copyright 2015 - 2018 IoT.bzh
#
# author: Romain Forlot <romain.forlot@iot.bzh>
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

# compute the default install directory
include(GNUInstallDirs)
get_filename_component(CMAKE_DIR ${CMAKE_ROOT} NAME)
set(DEFAULT_INSTALL_DIR ${CMAKE_INSTALL_DATADIR}/${CMAKE_DIR}/Modules)

# set the install directory, allowing its overwriting
set(INSTALL_DIR ${DEFAULT_INSTALL_DIR} CACHE PATH "Installation directory")

# install the module
INSTALL(FILES CMakeAfbTemplates.cmake DESTINATION ${INSTALL_DIR})
INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/ DESTINATION ${INSTALL_DIR}/CMakeAfbTemplates)
