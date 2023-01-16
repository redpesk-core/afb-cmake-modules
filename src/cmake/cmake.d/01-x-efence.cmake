# Optional LibEfence Malloc debug library
IF(CMAKE_BUILD_TYPE MATCHES DEBUG AND USE_EFENCE)
	CHECK_LIBRARY_EXISTS(efence malloc "" HAVE_LIBEFENCE)
	IF(HAVE_LIBEFENCE)
		MESSAGE("Linking with ElectricFence for debugging purposes...")
		SET(libefence_LIBRARIES "-lefence")
		list (APPEND link_libraries ${libefence_LIBRARIES})
	ENDIF(HAVE_LIBEFENCE)
ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG AND USE_EFENCE)
