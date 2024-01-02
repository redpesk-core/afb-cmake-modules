###########################################################################
# Copyright 2015-2024 IoT.bzh Company
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

# Loop on required package and add options
foreach (PKG_CONFIG ${PKG_REQUIRED_LIST})
	string(REGEX REPLACE "[<>]?=.*$" "" XPREFIX ${PKG_CONFIG})
	PKG_CHECK_MODULES(${XPREFIX} REQUIRED ${PKG_CONFIG})

	INCLUDE_DIRECTORIES(${${XPREFIX}_INCLUDE_DIRS})
	list(APPEND link_libraries ${${XPREFIX}_LDFLAGS})
	add_compile_options (${${XPREFIX}_CFLAGS})
endforeach(PKG_CONFIG)


