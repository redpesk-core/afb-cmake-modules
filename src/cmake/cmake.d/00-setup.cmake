###########################################################################
# Copyright (C) 2015-2025 IoT.bzh Company
#
# Author: Fulup Ar Foll <fulup@iot.bzh>
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

INCLUDE(FindPkgConfig)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)
INCLUDE(GNUInstallDirs)

# that setting is for project. I propose to drop that and to make
# standard use of PROJECT
set(CMP0048 1)


