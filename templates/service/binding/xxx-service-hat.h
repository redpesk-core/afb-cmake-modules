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
#ifndef SERVICEHAT_H
#define  SERVICEHAT_H

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <json-c/json.h>

#include <afb/afb-binding.h>

extern const struct afb_binding_interface *interface;

struct event
{
	struct event *next;
	struct afb_event event;
	char tag[1];
};

/* searchs the event of tag */
struct event *event_get(const char *tag);

/* deletes the event of tag */
int event_del(const char *tag);

/* creates the event of tag */
int event_add(const char *tag, const char *name);

int event_subscribe(struct afb_req request, const char *tag);

int event_unsubscribe(struct afb_req request, const char *tag);

int event_push(struct json_object *args, const char *tag);

void pingSample (struct afb_req request);

void pingFail (struct afb_req request);

void pingNull (struct afb_req request);

void pingBug (struct afb_req request);

void pingEvent(struct afb_req request);

// For samples https://linuxprograms.wordpress.com/2010/05/20/json-c-libjson-tutorial/
void pingJson (struct afb_req request);

void subcallcb (void *prequest, int iserror, json_object *object);

void subcall (struct afb_req request);

void eventadd (struct afb_req request);

void eventdel (struct afb_req request);

void eventsub (struct afb_req request);

void eventunsub (struct afb_req request);

void eventpush (struct afb_req request);

#endif