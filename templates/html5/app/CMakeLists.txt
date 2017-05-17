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

# Project target list
# --------------------
# Add target to project dependency list.
PROJECT_TARGET_ADD(html5-app)

	# Define project Targets
	add_custom_command(OUTPUT dist.prod
	DEPENDS ${TARGET_NAME}
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND [ -d app/dist.prod ] && npm install
	COMMAND [ -d app/dist.prod ] && gulp widget-config-prod
	COMMAND cp -r dist.prod ${CMAKE_CURRENT_BINARY_DIR})

	add_custom_target(${TARGET_NAME} ALL DEPENDS dist.prod)

	# Targets properties
	# ------------------
	# Target properties will be used to build package tree that will be
	# built using project_package_build.
	# OUTPUT_NAME:  Depends what is the name of your  output file, it is
	# mandatory to specify which is its name with target the property
	# OUTPUT_NAME for your target. If file name is same of your target then
	# use variable ${TARGET_NAME}.
	# LABELS: Choose between "BINDING", "HTDOCS", "EXECUTABLE" depending of
	# the type of your target.
	# PREFIX: This prefix will be added on the output file name specify with
	# OUTPUT_NAME. By default, there isn't PREFIX on target except on
	# library target with is "lib".
	SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES
		LABELS "HTDOCS"
		OUTPUT_NAME dist.prod)
