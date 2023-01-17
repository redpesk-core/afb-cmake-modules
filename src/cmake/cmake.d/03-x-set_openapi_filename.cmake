# Set the name of the OPENAPI definition JSON file for binding v2
macro(set_openapi_filename openapi_filename)
	set(OPENAPI_DEF ${openapi_filename}
	    CACHE STRING "OpenAPI JSON file name used to generate binding header file before building a binding v2 target.")
endmacro()

