/*
 * Copyright (C) 2015, 2016 "IoT.bzh"
 * Author "Fulup Ar Foll"
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
#include <stdio.h>
#include <string.h>
#include <json-c/json.h>

#include <afb/afb-binding.h>
#include "xxx-service-hat.h"

const struct afb_binding_interface *interface;

// NOTE: this sample does not use session to keep test a basic as possible
//       in real application most APIs should be protected with AFB_SESSION_CHECK
static const struct afb_verb_desc_v1 verbs[]= {
  {"ping"     , AFB_SESSION_NONE, pingSample  , "Ping the binder"},
  {"pingfail" , AFB_SESSION_NONE, pingFail    , "Ping that fails"},
  {"pingnull" , AFB_SESSION_NONE, pingNull    , "Ping which returns NULL"},
  {"pingbug"  , AFB_SESSION_NONE, pingBug     , "Do a Memory Violation"},
  {"pingJson" , AFB_SESSION_NONE, pingJson    , "Return a JSON object"},
  {"pingevent", AFB_SESSION_NONE, pingEvent   , "Send an event"},
  {"subcall",   AFB_SESSION_NONE, subcall     , "Call api/verb(args)"},
  {"eventadd",  AFB_SESSION_NONE, eventadd    , "adds the event of 'name' for the 'tag'"},
  {"eventdel",  AFB_SESSION_NONE, eventdel    , "deletes the event of 'tag'"},
  {"eventsub",  AFB_SESSION_NONE, eventsub    , "subscribes to the event of 'tag'"},
  {"eventunsub",AFB_SESSION_NONE, eventunsub  , "unsubscribes to the event of 'tag'"},
  {"eventpush", AFB_SESSION_NONE, eventpush   , "pushes the event of 'tag' with the 'data'"},
  {NULL}
};

static const struct afb_binding plugin_desc = {
	.type = AFB_BINDING_VERSION_1,
	.v1 = {
		.info = "xxxxxx service",
		.prefix = "xxxxxx",
		.verbs = verbs
	}
};

const struct afb_binding *afbBindingV1Register (const struct afb_binding_interface *itf)
{
	interface = itf;
	return &plugin_desc;
}
