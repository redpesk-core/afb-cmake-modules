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

file(GLOB project_cmakefiles ${PROJECT_APP_TEMPLATES_DIR}/cmake/cmake.d/[0-9][0-9]-*.cmake)
list(SORT project_cmakefiles)
file(GLOB home_cmakefiles $ENV{HOME}/.config/cmake.d/[0-9][0-9]-*.cmake)
list(SORT home_cmakefiles)
file(GLOB system_cmakefiles /etc/cmake.d/[0-9][0-9]-*.cmake)
list(SORT system_cmakefiles)

foreach(file ${system_cmakefiles} ${home_cmakefiles} ${project_cmakefiles})
	message(STATUS "Include: ${file}")
	include(${file})
endforeach()

macro(project_build)
	set (ARGSLIST ${ARGN})
	list(LENGTH ARGSLIST ARGSNUM)
	if(${ARGSNUM} GREATER 0)
		set(pattern "${ARGV0}")
	else()
		set(pattern "*")
	endif()

	project_subdirs_add(${pattern})
	project_targets_populate()
	project_package_build()
	project_closing_msg()
endmacro(project_build)