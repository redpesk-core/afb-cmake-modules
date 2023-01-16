# Define some checker binaries to verify input DATA files
# to be included in package. Schema aren't checked for now.
# Dummy checker about JSON.
set(LUA_CHECKER "luac" "-p" CACHE STRING "LUA compiler")
set(XML_CHECKER "xmllint" CACHE STRING "XML linter")
set(JSON_CHECKER "" CACHE STRING "JSON linter")

