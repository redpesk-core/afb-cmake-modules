#!/bin/bash

###########################################################################
# Copyright (C) 2017, 2018 IoT.bzh
#
# Author: Romain Forlot <romain.forlot@iot.bzh>
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

PORT=$1
SESID=sesid$$

# Research the Api name used
CFGFILE=$(find ${AFM_APP_INSTALL_DIR} -name "*json" -print | head -n1)
API=$(grep '\"api\"' ${CFGFILE} | cut -d'"' -f4)

declare -a testVerb

if [[ $(jq -r '.testVerb|type' $CFGFILE) == "array" ]]
then
	testVerbLength=$(jq '.testVerb|length' $CFGFILE)
	# Get all the verbs of the test api
	for (( idx=0; idx<testVerbLength; idx++ )) do
				testVerb[$idx]=$(jq -r ".testVerb[$idx].uid" ${CFGFILE})
	done
else
	testVerb[0]=$(jq -r ".testVerb.uid" ${CFGFILE})
fi

testVerbLength=${#testVerb[@]}
for (( idx=0; idx<testVerbLength; idx++ )) do
	echo "Launching ${testVerb[$idx]}"
        afb-client --uuid $SESID --sync ws://localhost:${PORT}/api "$API" "${testVerb[$idx]}" "${VERBARGS}"
done

afb-client --uuid $SESID ws://localhost:${PORT}/api "$API" "exit"
