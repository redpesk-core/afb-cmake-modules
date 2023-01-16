function(prevent_in_source_build)
	if(EXISTS ${CMAKE_SOURCE_DIR}/CMakeCache.txt
	 OR EXISTS ${CMAKE_SOURCE_DIR}/CMakeFiles)
		execute_process(
			COMMAND rm -f CMakeCacheForScript.cmake cmake_install.cmake
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
		message(FATAL_ERROR "\n${Red}**** ERROR: Building from the source directory isn't allowed ****\n"
		                          " You have to build from a separate directory.\n"
					  " Example 'mkdir build; cd build; cmake ..'\n"
					  " Check cmake manual to get hints.\n"
					  " \n"
					  " But before run the below command:${Green}\n"
					  "    rm -rf ${CMAKE_SOURCE_DIR}/CMakeFiles\n"
					  "    rm -f ${CMAKE_SOURCE_DIR}/CMakeCache.txt\n"
					  " ${White}\n"
					  )
	endif()
endfunction(prevent_in_source_build)


