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

# Project target list
# --------------------
# Add target to project dependency list. Name specified as argument will be
# added to the project target list and the variable ${TARGET_NAME} become
# available with that value.
PROJECT_TARGET_ADD(xxx)

	# Define project Targets
	add_library(${TARGET_NAME} MODULE
		${TARGET_NAME}-hat.c
		${TARGET_NAME}-cb.c
		)

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
		PREFIX "afb-"
		LABELS "BINDING"
		LINK_FLAGS ${BINDINGS_LINK_FLAG}
		OUTPUT_NAME ${TARGET_NAME}
	)

	# Link
	# ----
	# Library dependencies (include updates automatically). Linked to the
	# target.
	TARGET_LINK_LIBRARIES(${TARGET_NAME}
		${link_libraries})

	# Include
	# -------
	# Define target includes search and dependencies. Choose between PUBLIC,
	# PRIVATE or INTERFACE. PRIVATE and PUBLIC items will populate the
	# INCLUDE_DIRECTORIES property of <target>. PUBLIC and INTERFACE items
	# will populate the INTERFACE_INCLUDE_DIRECTORIES property of <target>.
	# The following arguments specify include directories.
	# INTERFACE_INCLUDE_DIRECTORIES will be read at the
	# TARGET_LINK_LIBRARIES step for others targets that link against this
	# target.
    	TARGET_INCLUDE_DIRECTORIES( ${TARGET_NAME}
        	PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}
    	)

	# installation directory
	INSTALL(TARGETS ${TARGET_NAME}
		LIBRARY DESTINATION ${BINDINGS_INSTALL_DIR})
