// Copyright 2022 Vladimir Pouzanov <farcaller@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ulid/ulid.dart';
import 'base_event.dart';

part 'client_event.g.dart';

const kClientEventType = '__client';

@JsonSerializable()
class ClientEvent extends BaseEvent {
  final String msg;

  // TODO: do we care bout time?
  ClientEvent(this.msg)
      : super(
            id: 'client__${Ulid()}', type: kClientEventType, time: 0, sig: '');

  factory ClientEvent.fromJson(Map<String, dynamic> json) {
    return _$ClientEventFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ClientEventToJson(this);

  @override
  Widget toWidget({String? charId}) {
    return Text(msg.toString(), style: const TextStyle(color: Colors.red));
  }
}
