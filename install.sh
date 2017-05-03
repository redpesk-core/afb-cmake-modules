#!/bin/bash
#
# Copyright (C) 2015, 2016 "IoT.bzh"
# Author "Romain Forlot" <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	 http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='tdbh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_components_path=()
_arg_debug=off

print_help ()
{
	echo "The general script's help msg"
	printf 'Usage: %s [-d|--(no-)debug] [-h|--help] <root-path>\n' "$0"
	printf "\t%s\n" "<root-path>: Project root path"
	printf "\t%s\n" "-d,--debug,--no-debug: Optional debug flag. (off by default)"
	printf "\t%s\n" "-h,--help: Prints help"
}

# THE PARSING ITSELF
while test $# -gt 0
do
	_key="$1"
	case "$_key" in
		-d*|--no-debug|--debug)
			_arg_debug="on"
			_next="${_key##-d}"
			if test -n "$_next" -a "$_next" != "$_key"
			then
				begins_with_short_option "$_next" && shift && set -- "-d" "-${_next}" "$@" || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
			fi
			test "${1:0:5}" = "--no-" && _arg_debug="off"
			;;
		-h*|--help)
			print_help
			exit 0
			;;
		*)
			_positionals+=("$1")
			;;
	esac
	shift
done

_positional_names=('_arg_root_path' )
_required_args_string="'root-path'"
test ${#_positionals[@]} -lt 1 && _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${#_positionals[@]}." 1
test ${#_positionals[@]} -gt 1 && _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
	eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
done

[ "${_arg_debug}" = "on" ] && echo "Copying template structure to your project root path: ${_arg_root_path}"
cp -rf template/etc template/AGLBuild template/packaging ${_arg_root_path}/

echo "Installation finished."
echo "Please customize the config.cmake file under the 'etc' directory of your project."
echo "Specify manually your target, you should look at samples provided in this repository to make yours."
echo "Then when you are ready to build, using 'AGLBuild' that will wrap CMake build command:"
echo "./AGLBuild package"
echo ""
echo "Or with the classic way : "
echo "mkdir -p build && cd build"
echo "cmake .. && make"
