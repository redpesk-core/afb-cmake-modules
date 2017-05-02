###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
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

CMAKE_MINIMUM_REQUIRED(VERSION 3.3)

include(${CMAKE_CURRENT_SOURCE_DIR}/etc/config.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/etc/macros.cmake)

# Add target to project dependency list
PROJECT_TARGET_ADD(native-example)

	# Define project Targets
	add_executable(${TARGET_NAME} xxxxxx-native-client.c
	)

	link_libraries(
		${CMAKE_THREAD_LIBS_INIT}
		${libafbwsc_LIBRARIES}
		${json-c_LIBRARIES}
		${libsystemd_LIBRARIES}
	)

	# Binder exposes a unique public entry point
	SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
		PREFIX ""
		LABELS "EXECUTABLE"
		OUTPUT_NAME ${TARGET_NAME})

	TARGET_INCLUDE_DIRECTORIES(${TARGET_NAME}
		PUBLIC	${libafbwsc_INCLUDE_DIRS}
			${json-c_INCLUDE_DIRS}
			${libsystemd_INCLUDE_DIRS})

	TARGET_LINK_LIBRARIES(${TARGET_NAME}
		afbwsc
		${link_libraries})

populate_widget()

build_widget()
