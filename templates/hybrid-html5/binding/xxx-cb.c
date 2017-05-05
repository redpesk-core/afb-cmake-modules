/*
 * Copyright (C) 2015, 2016 "IoT.bzh"
 * Author "Manuel Bachmann"
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define _GNU_SOURCE
#include <json-c/json.h>

#include <afb/afb-binding.h>
#include "xxx-hat.h"

void ping (struct afb_req request)
{
	static int pingcount = 0;

	json_object *query = afb_req_json(request);
	afb_req_success_f(request, NULL, "Ping Binder Daemon count=%d query=%s", ++pingcount, json_object_to_json_string(query));
}
