# Setup project and app-templates version variables
execute_process(COMMAND git describe --abbrev=0
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE GIT_PROJECT_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Get the git commit hash to append to the version
execute_process(COMMAND git rev-parse --short HEAD
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE GIT_COMMIT_HASH
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Detect unstaged or untracked changes
execute_process(COMMAND git status --short
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE GIT_IS_DIRTY
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET
)

# Include project configuration
# ------------------------------
if(NOT PROJECT_VERSION AND NOT GIT_PROJECT_VERSION AND NOT VERSION)
	message(FATAL_ERROR "${Red}No version found. Please set a version tag or PROJECT_VERSION cmake variable in your config.cmake. Abort!")
elseif(NOT PROJECT_VERSION AND GIT_PROJECT_VERSION)
	set(PROJECT_VERSION ${GIT_PROJECT_VERSION})
elseif(NOT PROJECT_VERSION AND VERSION)
	set(PROJECT_VERSION ${VERSION})
endif()

if(NOT PROJECT_DESCRIPTION)
    message(WARNING "${Yellow}No description found. Please set a PROJECT_DESCRIPTION cmake variable in your config.cmake.")
    set(PROJECT_DESCRIPTION "-")
endif()

if(NOT PROJECT_URL)
    message(WARNING "${Yellow}No homepage url found. Please set a PROJECT_URL cmake variable in your config.cmake.")
endif()

# Release additionnals informations isn't supported so setting project
# attributes then add the dirty flag if git repo not sync'ed
if(CMAKE_VERSION VERSION_GREATER 3.11)
	if(PROJECT_URL)
		project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES} DESCRIPTION ${PROJECT_DESCRIPTION} HOMEPAGE_URL ${PROJECT_URL})
	else()
		project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES} DESCRIPTION ${PROJECT_DESCRIPTION})
	endif()
else()
	project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES})
endif()
if(${GIT_IS_DIRTY})
	set(PROJECT_VERSION "${PROJECT_VERSION}-${GIT_COMMIT_HASH}-dirty")
elseif(${COMMIT_VERSION})
	set(PROJECT_VERSION "${PROJECT_VERSION}-${GIT_COMMIT_HASH}")
else()
	set(PROJECT_VERSION "${PROJECT_VERSION}")
endif()


