# strange setting maybe to be removed

macro(set_install_prefix)
	if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND INSTALL_PREFIX)
		message("-- Overwrite the CMAKE default install prefix with ${INSTALL_PREFIX}")
		set(CMAKE_INSTALL_PREFIX ${INSTALL_PREFIX} CACHE PATH "Install prefix" FORCE)
	endif()

	# (BUG!!!) as PKG_CONFIG_PATH does not work [should be an env variable]
	# ---------------------------------------------------------------------
	set(CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/lib64/pkgconfig ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig CACHE PATH 'Prefix Path list used by pkgconfig module')
	set(LD_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib64 ${CMAKE_INSTALL_PREFIX}/lib CACHE PATH 'Path list where to search for libraries')
endmacro()

