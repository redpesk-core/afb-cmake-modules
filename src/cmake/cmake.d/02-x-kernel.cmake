
file(STRINGS "${BUILD_ENV_SYSROOT}/usr/include/linux/version.h" LINUX_VERSION_CODE_LINE REGEX "LINUX_VERSION_CODE")

string(REGEX MATCH "[0-9]+" LINUX_VERSION_CODE ${LINUX_VERSION_CODE_LINE})
math(EXPR a "${LINUX_VERSION_CODE} >> 16")
math(EXPR b "(${LINUX_VERSION_CODE} >> 8) & 255")
math(EXPR c "(${LINUX_VERSION_CODE} & 255)")

set(KERNEL_VERSION "${a}.${b}.${c}")

# Check Kernel mandatory version, will fail the configuration if required version not matched.
if (kernel_mandatory_version)
	message("${Cyan}-- Check kernel_mandatory_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
	if (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
		message(FATAL_ERROR "${Red}**** \
		FATAL: Require at least ${kernel_mandatory_version} please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.")
	endif (KERNEL_VERSION VERSION_LESS ${kernel_mandatory_version})
endif(kernel_mandatory_version)

# Check Kernel minimal version just print a Warning about missing features
# and set a definition to be used as preprocessor condition in code to disable
# incompatibles features.
if (kernel_minimal_version)
	message ( "${Cyan}-- Check kernel_minimal_version (found kernel version ${KERNEL_VERSION})${ColourReset}")
	if (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
		message(WARNING "${Yellow}**** \
		Warning: Some feature(s) require at least ${kernel_minimal_version}. \
		Please use a recent kernel or source your SDK environment then clean and reconfigure your CMake project.\
		${ColourReset}")
	else (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
		add_definitions(-DKERNEL_MINIMAL_VERSION_OK)
	endif (KERNEL_VERSION VERSION_LESS ${kernel_minimal_version})
endif(kernel_minimal_version)

