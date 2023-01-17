# for generation of info JSON text, defines macros
#  - generate_json
#  - generate_info_json_array
#  - generate_info_json_pointer
#  - info_verb_generate

macro(generate_json TARGET_NAME FIRSTLINE INFILE OUTFILE)
	target_sources(${TARGET_NAME} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE})
	add_custom_command(
		OUTPUT ${OUTFILE}
		COMMAND echo "${FIRSTLINE}" > ${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}
		COMMAND sed 's/\"/\\\\\"/g\;s/^[ \t]*/&\"/\;s/[ \t]*$$/\"&/' ${CMAKE_CURRENT_SOURCE_DIR}/${INFILE} >> ${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}
		COMMAND echo '\;' >> ${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}
		DEPENDS ${INFILE}
	)

endmacro()

macro(generate_info_json_array TARGET_NAME VARNAME INFILE OUTFILE)
	generate_json("${TARGET_NAME}" "const char ${VARNAME}[] =" "${INFILE}" "${OUTFILE}")
endmacro()

macro(generate_info_json_pointer TARGET_NAME VARNAME INFILE OUTFILE)
	generate_json("${TARGET_NAME}" "const char *${VARNAME} =" "${INFILE}" "${OUTFILE}")
endmacro()

macro(info_verb_generate TARGET_NAME)
	generate_info_json_pointer("${TARGET_NAME}" info_verbS info_verb.json json_info.c)
endmacro()

